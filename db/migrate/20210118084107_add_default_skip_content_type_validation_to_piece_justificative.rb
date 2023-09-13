class AddDefaultSkipContentTypeValidationToPieceJustificative < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:add_default_skip_content_type_validation_to_piece_justificative'].invoke if AfterParty::TaskRecord.where(version: 20210118084107).empty?
  end
end
