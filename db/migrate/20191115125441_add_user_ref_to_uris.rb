class AddUserRefToUris < ActiveRecord::Migration[5.2]
  def change
    add_reference :uris, :user, foreign_key: true, null: false
  end
end
