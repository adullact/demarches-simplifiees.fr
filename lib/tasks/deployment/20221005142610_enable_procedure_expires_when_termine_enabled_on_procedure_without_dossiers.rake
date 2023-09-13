namespace :after_party do
  desc 'Deployment task: enable_procedure_expires_when_termine_enabled_on_procedure_without_dossiers'
  task enable_procedure_expires_when_termine_enabled_on_procedure_without_dossiers: :environment do
    puts "Running deploy task 'enable_procedure_expires_when_termine_enabled_on_procedure_without_dossiers'"

    Procedure.reset_column_information
    # Put your task implementation HERE.
    procedure_without_expiration = Procedure.where(procedure_expires_when_termine_enabled: false)
    progress = ProgressReport.new(procedure_without_expiration.count)
    procedure_without_expiration.find_each do |procedure|
      if procedure.dossiers.count.zero?
        begin
          procedure.update(max_duree_conservation_dossiers_dans_ds: Procedure::NEW_MAX_DUREE_CONSERVATION, duree_conservation_dossiers_dans_ds: [procedure.duree_conservation_dossiers_dans_ds, Procedure::NEW_MAX_DUREE_CONSERVATION].min, procedure_expires_when_termine_enabled: true)
        rescue StandardError => e
          rake_puts "pb with procedure: #{procedure.id}, #{e.message}"
        end
      end
      progress.inc
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
