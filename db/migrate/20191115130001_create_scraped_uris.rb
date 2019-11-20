class CreateScrapedUris < ActiveRecord::Migration[5.2]
  def change
    create_table :scraped_uris do |t|
      t.references :uri, foreign_key: true, null: false
      t.references :user, foreign_key: true, null: false
      t.integer :depth, null: false, default: 0
      t.jsonb :links, default: {}

      t.timestamps
    end
  end
end
