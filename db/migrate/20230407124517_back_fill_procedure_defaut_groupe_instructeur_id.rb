class BackFillProcedureDefautGroupeInstructeurId < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:back_fill_procedure_defaut_groupe_instructeur_id'].invoke
  end
end
