class CreateUris < ActiveRecord::Migration[5.2]
  def change
    create_table :uris do |t|
      t.string :name
      t.string :host

      t.timestamps
    end
  end
end
