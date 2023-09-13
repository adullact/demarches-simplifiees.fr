class FixDossiersExpirationDates < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:fix_dossiers_expiration_dates'].invoke if AfterParty::TaskRecord.where(version: 20220408100411).empty?
  end
end
