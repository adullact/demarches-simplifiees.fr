class FixTypesDeChampRevisions < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:fix_types_de_champ_revisions'].invoke if AfterParty::TaskRecord.where(version: 20201218163035).empty?
  end
end
