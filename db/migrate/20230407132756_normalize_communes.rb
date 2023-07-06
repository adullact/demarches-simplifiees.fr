class NormalizeCommunes < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:normalize_communes'].invoke
  end
end
