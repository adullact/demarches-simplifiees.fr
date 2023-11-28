class ForceDossiersToFillMissingIndividual < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:force_dossiers_to_fill_missing_individual'].invoke if AfterParty::TaskRecord.where(version: 20230707121855).empty?
  end
end
