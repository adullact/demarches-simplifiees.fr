class StripTypeDeChampLibelle < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:strip_type_de_champ_libelle'].invoke
  end
end
