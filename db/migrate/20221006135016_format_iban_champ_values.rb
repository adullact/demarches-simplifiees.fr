class FormatIbanChampValues < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:format_iban_champ_values'].invoke if AfterParty::TaskRecord.where(version: 20221006135016).empty?
  end
end
