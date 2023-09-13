class AddDefaultSkipValidationToPieceJustificative < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:add_default_skip_validation_to_piece_justificative'].invoke if AfterParty::TaskRecord.where(version: 20200708101123).empty?
  end
end
