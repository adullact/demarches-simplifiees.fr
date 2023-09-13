class FixBadInvitationTargetedUserLink < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:fix_bad_invitation_targeted_user_link'].invoke if AfterParty::TaskRecord.where(version: 20230131154015).empty?
  end
end
