class FixNotNormalizedChampsCommune < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:fix_not_normalized_champs_commune'].invoke if AfterParty::TaskRecord.where(version: 20231110092044).empty?
  end
end
