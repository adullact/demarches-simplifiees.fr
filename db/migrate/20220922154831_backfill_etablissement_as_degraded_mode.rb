class BackfillEtablissementAsDegradedMode < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:backfill_etablissement_as_degraded_mode'].invoke if AfterParty::TaskRecord.where(version: 20220922154831).empty?
  end
end
