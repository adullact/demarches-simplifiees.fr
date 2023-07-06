class UpdateProcedureDossiersCount < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:update_procedure_dossiers_count'].invoke
  end
end
