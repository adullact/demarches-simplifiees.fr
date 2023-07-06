class NormalizeCommuneCodeDepartement < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:normalize_commune_code_departement'].invoke
  end
end
