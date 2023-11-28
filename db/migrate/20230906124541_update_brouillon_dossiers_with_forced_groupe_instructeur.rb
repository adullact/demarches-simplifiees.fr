class UpdateBrouillonDossiersWithForcedGroupeInstructeur < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:update_brouillon_dossiers_with_forced_groupe_instructeur'].invoke if AfterParty::TaskRecord.where(version: 20230906124541).empty?
  end
end
