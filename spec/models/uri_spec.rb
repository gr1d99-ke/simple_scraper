# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Uri, type: :model do
  describe 'Associations' do
    specify { should belong_to(:user) }
  end
end
