class NullifyCommentaireDeletedInstructeurs < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:nullify_commentaire_deleted_instructeurs'].invoke if AfterParty::TaskRecord.where(version: 20221019094123).empty?
  end
end
