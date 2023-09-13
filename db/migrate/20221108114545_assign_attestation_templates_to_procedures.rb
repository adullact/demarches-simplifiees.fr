class AssignAttestationTemplatesToProcedures < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:assign_attestation_templates_to_procedures'].invoke if AfterParty::TaskRecord.where(version: 20221108114545).empty?
  end
end
