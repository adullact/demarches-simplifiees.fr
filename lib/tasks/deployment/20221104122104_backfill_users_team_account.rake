namespace :after_party do
  desc 'Deployment task: backfill_users_team_account'
  task backfill_users_team_account: :environment do
    User.where('email ilike ?', "%@beta.gouv.fr").joins(:administrateur).in_batches do |batch|
      batch.update_all(team_account: true)
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
