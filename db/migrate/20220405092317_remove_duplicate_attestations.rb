class RemoveDuplicateAttestations < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:remove_duplicate_attestations'].invoke if AfterParty::TaskRecord.where(version: 20220405092317).empty?
  end
end
