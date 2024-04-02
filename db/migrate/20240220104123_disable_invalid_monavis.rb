class DisableInvalidMonavis < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:disable_invalid_monavis'].invoke if AfterParty::TaskRecord.where(version: 20240220104123).empty?
  end
end
