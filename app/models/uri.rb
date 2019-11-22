class Uri < ApplicationRecord
  belongs_to :user
  has_many :scraped_uris, dependent: :destroy

  before_save :remove_last_slash

  def remove_last_slash
    if host.end_with?("/")
      self.host = host[0...-1]
    end
  end
end
