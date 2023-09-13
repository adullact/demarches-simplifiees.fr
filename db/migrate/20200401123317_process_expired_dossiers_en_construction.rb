class ProcessExpiredDossiersEnConstruction < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:process_expired_dossiers_en_construction'].invoke if AfterParty::TaskRecord.where(version: 20200401123317).empty?
  end
end
