class AddAPIParticulierTokenToProcedures < ActiveRecord::Migration[6.0]
  def change
    add_column :procedures, :api_particulier_token, :string
  end
end
