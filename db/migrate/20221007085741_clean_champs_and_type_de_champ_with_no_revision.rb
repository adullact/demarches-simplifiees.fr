class CleanChampsAndTypeDeChampWithNoRevision < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:clean_champs_and_type_de_champ_with_no_revision'].invoke if AfterParty::TaskRecord.where(version: 20221007085741).empty?
  end
end
