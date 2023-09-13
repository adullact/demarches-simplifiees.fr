class NullExportsKeyToUuid < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:null_exports_key_to_uuid'].invoke if AfterParty::TaskRecord.where(version: 20210402000000).empty?
  end
end
