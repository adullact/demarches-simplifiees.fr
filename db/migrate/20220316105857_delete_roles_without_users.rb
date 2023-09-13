class DeleteRolesWithoutUsers < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:delete_roles_without_users'].invoke if AfterParty::TaskRecord.where(version: 20220316105857).empty?
  end
end
