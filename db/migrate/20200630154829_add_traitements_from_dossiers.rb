class AddTraitementsFromDossiers < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:add_traitements_from_dossiers'].invoke if AfterParty::TaskRecord.where(version: 20200630154829).empty?
  end
end
