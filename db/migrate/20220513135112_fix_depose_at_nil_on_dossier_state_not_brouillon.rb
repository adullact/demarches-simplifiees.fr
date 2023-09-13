class FixDeposeAtNilOnDossierStateNotBrouillon < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:fix_depose_at_nil_on_dossier_state_not_brouillon'].invoke if AfterParty::TaskRecord.where(version: 20220513135112).empty?
  end
end
