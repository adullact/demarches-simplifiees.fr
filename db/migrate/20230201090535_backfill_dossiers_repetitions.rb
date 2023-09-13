class BackfillDossiersRepetitions < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:backfill_dossiers_repetitions'].invoke if AfterParty::TaskRecord.where(version: 20230201090535).empty?
  end
end
