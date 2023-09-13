class SetDossiersProcessedAt < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:set_dossiers_processed_at'].invoke if AfterParty::TaskRecord.where(version: 20211110093332).empty?
  end
end
