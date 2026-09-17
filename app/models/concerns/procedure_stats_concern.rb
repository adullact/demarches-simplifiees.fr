# frozen_string_literal: true

module ProcedureStatsConcern
  extend ActiveSupport::Concern

  NB_DAYS_RECENT_DOSSIERS = 30
  # Percentage of dossiers considered to compute the 'usual traitement time'.
  # For instance, a value of '90' means that the usual traitement time will return
  # the duration under which 90% of the given dossiers are closed.
  USUAL_TRAITEMENT_TIME_PERCENTILE = 90

  def stats_usual_traitement_time
    stats_cache_fetch("#{cache_key_with_version}/stats_usual_traitement_time") do
      usual_traitement_time_for_recent_dossiers(NB_DAYS_RECENT_DOSSIERS)
    end
  end

  def stats_usual_traitement_time_by_month_in_days
    stats_cache_fetch("#{cache_key_with_version}/stats_usual_traitement_time_by_month_in_days") do
      usual_traitement_time_by_month_in_days
    end
  end

  # On very large procedures the stats query can hit the statement timeout; these
  # stats decorate public pages (commencer, dossier status, the public stats API),
  # which must render anyway. Serve nil and negative-cache it briefly so we don't
  # hammer the database until the next attempt.
  def stats_cache_fetch(key, &)
    Rails.cache.fetch(key, expires_in: 12.hours, &)
  rescue ActiveRecord::QueryCanceled
    Rails.cache.write(key, nil, expires_in: 1.hour)
    nil
  end

  def stats_dossiers_funnel
    stats_cache_fetch("#{cache_key_with_version}/stats_dossiers_funnel") do
      [
        ['Tous (dont brouillon)', dossiers.visible_by_user_or_administration.count + nb_dossiers_termines_supprimes],
        ['Déposés', dossiers.visible_by_administration.count + nb_dossiers_termines_supprimes],
        ['Instruction débutée', dossiers.visible_by_administration.state_instruction_commencee.count + nb_dossiers_termines_supprimes],
        ['Traités', nb_dossiers_termines],
      ]
    end
  end

  def stats_termines_states
    stats_cache_fetch("#{cache_key_with_version}/stats_termines_states") do
      [
        ['Acceptés', percentage(nb_dossiers_termines_in_state(:accepte), nb_dossiers_termines)],
        ['Refusés', percentage(nb_dossiers_termines_in_state(:refuse), nb_dossiers_termines)],
        ['Classés sans suite', percentage(nb_dossiers_termines_in_state(:sans_suite), nb_dossiers_termines)],
      ]
    end
  end

  def stats_termines_by_week
    stats_cache_fetch("#{cache_key_with_version}/stats_termines_by_week") do
      now = Time.zone.now
      chart_data = dossiers.includes(:traitements)
        .visible_by_administration
        .state_termine
        .where(traitements: { processed_at: (now.beginning_of_week - 6.months)..now.end_of_week })

      dossier_state_values = chart_data.pluck(:state).sort.uniq

      dossier_state_values
        .map do |state|
              {
                name: state,
                data: chart_data .where(state: state) .group_by_week do |dossier|
                  dossier.traitements.first.processed_at
                end.map { |k, v| [k, v.count] }.to_h.transform_keys { |week| pretty_week(week) },
              }
            end
    end
  end

  def traitement_times(date_range)
    Traitement.for_traitement_time_stats(self)
      .where(processed_at: date_range)
      .pluck('dossiers.depose_at', :processed_at)
      .map { |depose_at, processed_at| { depose_at: depose_at, processed_at: processed_at } }
  end

  def usual_traitement_time_by_month_in_days
    traitement_times(first_processed_at..last_considered_processed_at)
      .group_by { |t| t[:processed_at].beginning_of_month }
      .transform_values { |month| month.map { |h| h[:processed_at] - h[:depose_at] } }
      .transform_values do |traitement_times_for_month|
        seconds = winsorized_mean(traitement_times_for_month).ceil
        seconds == 0 ? nil : convert_seconds_in_days(seconds)
      end
      .transform_keys { |month| pretty_month(month) }
  end

  # The winsorized mean is a useful estimator because by retaining the outliers without taking them too literally, it is less sensitive to observations at the extremes than the straightforward mean, and will still generate a reasonable estimate of central tendency or mean for almost all statistical models. In this regard it is referred to as a robust estimator.
  def winsorized_mean(data, lower_perc = 5, upper_perc = 95)
    data_points = data.sort
    lower_bound_percentile = data_points.percentile(lower_perc)
    upper_bound_percentile = data_points.percentile(upper_perc)

    winsorized_data = data_points.map { |data_point| data_point < lower_bound_percentile ? lower_bound_percentile : (data_point > upper_bound_percentile ? upper_bound_percentile : data_point) }

    winsorized_data.sum.to_f / winsorized_data.size
  end

  def usual_traitement_time_for_recent_dossiers(nb_days)
    now = Time.zone.now
    clusters_count = 3

    traitement_time =
      traitement_times((now - nb_days.days)..now)
        .map { |times| times[:processed_at] - times[:depose_at] }
        .sort
    if traitement_time.size >= clusters_count
      traitement_time.each_slice((traitement_time.size.to_f / clusters_count.to_f).ceil)
        .map { _1.percentile(USUAL_TRAITEMENT_TIME_PERCENTILE) }
    else
      nil
    end
  end

  private

  def nb_dossiers_termines
    @nb_dossiers_termines ||= dossiers.visible_by_administration.state_termine.count + nb_dossiers_termines_supprimes
  end

  def nb_dossiers_termines_supprimes
    @nb_dossiers_termines_supprimes ||= deleted_dossiers.state_termine.count
  end

  # `nb_dossiers_termines` counts deleted dossiers as well, so the per-state
  # numerators have to count them too, otherwise the shares don't add up to 100%.
  def nb_dossiers_termines_in_state(state)
    dossiers.visible_by_administration.where(state:).count + deleted_dossiers.where(state:).count
  end

  def first_processed_at
    Traitement.for_traitement_time_stats(self).pick(:processed_at)
  end

  def last_considered_processed_at
    (1.month.ago).end_of_month
  end

  def convert_seconds_in_days(seconds)
    (seconds / 60.0 / 60.0 / 24.0).ceil
  end

  # A procedure with no dossier terminé would divide 0 by 0 and yield NaN, which
  # the JSON encoder turns into null: the public stats API then serves null shares
  # and the pie chart renders empty.
  def percentage(value, total)
    return 0.0 if total.zero?

    (100 * value / total.to_f).round(1)
  end

  def pretty_month(month)
    I18n.l(month.to_date, format: :month_year)
  end

  def pretty_week(week)
    I18n.l(week.to_date, format: :day_month_short)
  end
end
