class NormalizeRegions < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:normalize_regions'].invoke if AfterParty::TaskRecord.where(version: 20230207144243).empty?
  end
end
