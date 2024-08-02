class BackfillAttestationTemplateV2AsDraft < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:backfill_attestation_template_v2_as_draft'].invoke if AfterParty::TaskRecord.where(version: 20240528155104).empty?
  end
end
