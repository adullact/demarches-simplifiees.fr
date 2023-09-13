class BackfillClaimantTypeOnAvisTable < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:backfill_claimant_type_on_avis_table'].invoke if AfterParty::TaskRecord.where(version: 20210307144755).empty?
  end
end
