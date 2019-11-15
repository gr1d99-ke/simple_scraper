class CreateScrapedUris < ActiveRecord::Migration[5.2]
  def change
    create_table :scraped_uris do |t|
      t.references :uri, foreign_key: true
      t.references :user, foreign_key: true
      t.jsonb :links

      t.timestamps
    end
  end
end
