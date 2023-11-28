class FixChampsCommunes99 < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:fix_champs_communes_99'].invoke if AfterParty::TaskRecord.where(version: 20230615175221).empty?
  end
end
