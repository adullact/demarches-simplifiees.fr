class NormalizeDepartements < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:normalize_departements'].invoke if AfterParty::TaskRecord.where(version: 20230208084036).empty?
  end
end
