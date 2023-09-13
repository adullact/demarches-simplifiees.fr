class CleanupDeletedDossiers < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:cleanup_deleted_dossiers'].invoke if AfterParty::TaskRecord.where(version: 20200326133630).empty?
  end
end
