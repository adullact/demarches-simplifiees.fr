class BackfillInvitesMissingExistingUser < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:backfill_invites_missing_existing_user'].invoke if AfterParty::TaskRecord.where(version: 20231226140149).empty?
  end
end
