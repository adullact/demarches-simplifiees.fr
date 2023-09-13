class BackfillExpertsProcedureIdOnAvisTable < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:backfill_experts_procedure_id_on_avis_table'].invoke if AfterParty::TaskRecord.where(version: 20210118142539).empty?
  end
end
