class ReviseAttestationTemplates < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:revise_attestation_templates'].invoke if AfterParty::TaskRecord.where(version: 20220112184331).empty?
  end
end
