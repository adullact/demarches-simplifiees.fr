class NormalizePaysValues < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:normalize_pays_values'].invoke if AfterParty::TaskRecord.where(version: 20230103170917).empty?
  end
end
