class FixDefautGroupeInstructeurIdForClonedProcedure < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:fix_defaut_groupe_instructeur_id_for_cloned_procedure'].invoke
  end
end
