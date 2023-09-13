class SeedHiddenAtDossiers < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:seed_hidden_at_dossiers'].invoke if AfterParty::TaskRecord.where(version: 20220309101504).empty?
  end
end
