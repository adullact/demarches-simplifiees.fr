class FixProcedureRevisionPublieeWithoutPublishedAt < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:fix_procedure_revision_publiee_without_published_at'].invoke
  end
end
