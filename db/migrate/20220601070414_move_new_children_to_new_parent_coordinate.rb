class MoveNewChildrenToNewParentCoordinate < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:move_new_children_to_new_parent_coordinate'].invoke if AfterParty::TaskRecord.where(version: 20220601070414).empty?
  end
end
