class PurgeMotivationDossiersNotTermine < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:purge_motivation_dossiers_not_termine'].invoke if AfterParty::TaskRecord.where(version: 20230721142825).empty?
  end
end
