require "rails_helper"

describe UriForm do
  describe "Validations" do
    let(:user) { FactoryBot.create(:user) }
    let(:valid_params) { { name: "test", host: "https://www.example.com", user_id: user.id } }

    context "when params are valid" do
      let(:form) { described_class.new(Uri.new) }

      it "returns true" do
        expect(form.validate(valid_params)).to be_truthy
      end

      it "saves uri to database" do
        expect do
          form.validate(valid_params)
          form.save
        end.to change(Uri, :count).from(0).to(1)
      end
    end

    context "when params are not valid" do
      let(:form) { described_class.new(Uri.new) }

      context "when name is not unique" do
        before do
          other_form = described_class.new(Uri.new)
          other_form.save if other_form.validate(valid_params)
        end

        it "sets error message" do
          expect(form.validate(valid_params)).to be_falsey
          expect(form.errors.details.keys.length).to be(1)
          expect(form.errors.details[:name].present?).to be_truthy
        end
      end

      context "when host is not present" do
        let(:params) { { name: "test", user_id: user.id } }

        it "sets error message" do
          expect(form.validate(params)).to be_falsey
          expect(form.errors.details.keys.length).to be(1)
          expect(form.errors.details[:host].present?).to be_truthy
        end
      end

      context "when host is not valid" do
        let(:params) { { name: "test", user_id: user.id, host: "1" } }

        it "sets error message" do
          expect(form.validate(params)).to be_falsey
          expect(form.errors.details.keys.length).to be(1)
          expect(form.errors.details[:host].present?).to be_truthy
        end
      end

      context "when user_id is not present" do
        let(:params) { { name: "test", host: "http://www.example.com" } }

        it "contains error message" do
          expect(form.validate(params)).to be_falsey
          expect(form.errors.details.keys.length).to be(1)
          expect(form.errors.details[:user_id].present?).to be_truthy
        end
      end
    end
  end
end
