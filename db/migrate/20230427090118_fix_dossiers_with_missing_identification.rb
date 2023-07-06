class FixDossiersWithMissingIdentification < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:fix_dossiers_with_missing_identification'].invoke
  end
end
