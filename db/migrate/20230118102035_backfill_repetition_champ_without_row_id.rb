class BackfillRepetitionChampWithoutRowId < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:backfill_repetition_champ_without_row_id'].invoke if AfterParty::TaskRecord.where(version: 20230118102035).empty?
  end
end
