class BlockDubiousEmail < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:block_dubious_email'].invoke if AfterParty::TaskRecord.where(version: 20240530090353).empty?
  end
end
