class BackfillUsersTeamAccount < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:backfill_users_team_account'].invoke if AfterParty::TaskRecord.where(version: 20221104122104).empty?
  end
end
