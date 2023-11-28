class FixPrefilledEmptyIndividual < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:fix_prefilled_empty_individual'].invoke if AfterParty::TaskRecord.where(version: 20230918143300).empty?
  end
end
