class RenameConservationExtension < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:rename_conservation_extension'].invoke if AfterParty::TaskRecord.where(version: 20210429172327).empty?
  end
end
