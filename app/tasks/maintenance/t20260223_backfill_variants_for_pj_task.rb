# frozen_string_literal: true

module Maintenance
  class T20260223BackfillVariantsForPjTask < MaintenanceTasks::Task
    # Enqueues jobs to generate thumbnails for files (images and/or PDFs)
    # for dossiers submitted between two dates.
    #
    # Unlike CreateVariantsForPjOfLatestDossiersTask which processes synchronously,
    # this task enqueues jobs for each dossier.
    #
    # This task should be performed cautiously, using a limited number of files,
    # preferably at night and on weekends.

    attribute :start_text, :string
    validates :start_text, presence: true

    attribute :end_text, :string
    validates :end_text, presence: true

    attribute :file_type, :string
    validates :file_type, inclusion: { in: ['image', 'pdf', ''] }

    attribute :spread_duration_hours, :integer, default: 6
    validates :spread_duration_hours, numericality: { greater_than: 0 }

    def collection
      start_date = DateTime.parse(start_text)
      end_date = DateTime.parse(end_text)

      Dossier
        .state_en_construction_ou_instruction
        .where(depose_at: start_date..end_date)
    end

    def process(dossier)
      require "vips"

      BackfillVariantsForDossierJob.set(wait: rand(0..spread_duration_hours.hours)).perform_later(dossier.id, file_type)
    end
  end
end
