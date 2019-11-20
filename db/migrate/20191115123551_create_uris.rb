class CreateUris < ActiveRecord::Migration[5.2]
  def change
    create_table :uris do |t|
      t.string :name, null: false
      t.string :host, null: false

      t.timestamps
    end
  end
end
