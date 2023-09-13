class CopyUserAssociationToUserRelatedModels < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:copy_user_association_to_user_related_models'].invoke if AfterParty::TaskRecord.where(version: 20220310115522).empty?
  end
end
