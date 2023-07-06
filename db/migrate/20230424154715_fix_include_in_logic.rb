class FixIncludeInLogic < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:fix_include_in_logic'].invoke
  end
end
