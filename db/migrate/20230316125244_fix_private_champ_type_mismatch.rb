class FixPrivateChampTypeMismatch < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:fix_private_champ_type_mismatch'].invoke
  end
end
