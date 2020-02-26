# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'Associations' do
    specify { should have_many(:uris) }
    specify { should have_many(:scraped_uris) }
  end
end
