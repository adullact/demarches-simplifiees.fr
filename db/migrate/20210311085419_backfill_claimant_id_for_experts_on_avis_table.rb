class BackfillClaimantIdForExpertsOnAvisTable < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:backfill_claimant_id_for_experts_on_avis_table'].invoke if AfterParty::TaskRecord.where(version: 20210311085419).empty?
  end
end
