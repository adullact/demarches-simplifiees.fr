class FixChildTypesDeChamp < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:fix_child_types_de_champ'].invoke if AfterParty::TaskRecord.where(version: 20220512072704).empty?
  end
end
