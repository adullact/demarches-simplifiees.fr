# frozen_string_literal: true

module Maintenance
  class T20260916stripWhitespaceFromSiretExternalIdTask < MaintenanceTasks::Task
    # `normalizes :external_id` strips whitespace on assignment, but
    # T20251029backfillChampSiretExternalStateTask filled the column with
    # Arel.sql('champs.value'), a raw expression Rails never casts: the champs it
    # moved still hold the siret with the spaces the user typed. Those build a
    # malformed API Entreprise URL that curl refuses before any call goes out.
    #
    # One siret champ every ~286 rows: asking for them in primary key order, as
    # batching over the relation does, makes every batch walk ~286k rows before
    # it has filled, and the statement timeout cuts it. Resolving their ids up
    # front does not work either — it takes minutes, and job-iteration rebuilds
    # the collection on a fresh Task instance every 5 minutes, so the job would
    # restart that query before the cursor ever advanced.
    #
    # Walking the primary key in fixed ranges instead: the collection costs two
    # index lookups however large the table, it is identical on every
    # resumption, and each UPDATE is bounded by a range rather than by a count
    # of matches, so no statement ever approaches the timeout.
    #
    # One UPDATE per range, by primary key, no record instantiated: neither the
    # champ nor its dossier is dated, so nothing moves up the instructeur list.

    RANGE_SIZE = 1_000_000

    def collection
      first_id = ChampData.minimum(:id)
      return [] if first_id.nil?

      (first_id..ChampData.maximum(:id)).step(RANGE_SIZE).to_a
    end

    def process(from)
      Champs::SiretChamp
        .where(id: from...(from + RANGE_SIZE))
        .where("external_id ~ '[[:space:]]'")
        .update_all("external_id = regexp_replace(external_id, '[[:space:]]', '', 'g')")
    end
  end
end
