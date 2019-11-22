class UpdateLinksColumnInScrapedUris < ActiveRecord::Migration[5.2]
  def change
    change_column_default :scraped_uris,
                          :links,
                          from: {},
                          to: { total: 0 }
  end
end
