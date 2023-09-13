class RenameEmailEventDolistMethod < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:rename_email_event_dolist_method'].invoke if AfterParty::TaskRecord.where(version: 20230203155423).empty?
  end
end
