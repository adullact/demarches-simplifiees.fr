class FixChampEtablissement < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:fix_champ_etablissement'].invoke if AfterParty::TaskRecord.where(version: 20200527124112).empty?
  end
end
