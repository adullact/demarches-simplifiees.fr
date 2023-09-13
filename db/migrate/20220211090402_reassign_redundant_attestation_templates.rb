class ReassignRedundantAttestationTemplates < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:reassign_redundant_attestation_templates'].invoke if AfterParty::TaskRecord.where(version: 20220211090402).empty?
  end
end
