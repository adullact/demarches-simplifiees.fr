class BackfillRowIdOnChamps < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:backfill_row_id_on_champs'].invoke if AfterParty::TaskRecord.where(version: 20221215135522).empty?
  end
end
