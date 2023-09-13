class BackfillExpertsProcedureIdOnAvisTableAgain < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:backfill_experts_procedure_id_on_avis_table_again'].invoke if AfterParty::TaskRecord.where(version: 20210324081552).empty?
  end
end
