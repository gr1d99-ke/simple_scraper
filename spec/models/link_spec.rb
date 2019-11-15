require 'rails_helper'

RSpec.describe Link, type: :model do
  describe "Validations" do
    specify { should validate_presence_of(:name) }
    specify { should validate_uniqueness_of(:name) }
  end
end
