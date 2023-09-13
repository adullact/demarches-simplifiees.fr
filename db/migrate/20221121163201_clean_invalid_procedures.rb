class CleanInvalidProcedures < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:clean_invalid_procedures'].invoke if AfterParty::TaskRecord.where(version: 20221121163201).empty?
  end
end
