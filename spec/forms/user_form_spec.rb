# frozen_string_literal: true

require 'rails_helper'

describe UserForm do
  describe 'Validations' do
    let(:valid_params) { { email: Faker::Internet.email, password: 'password' } }

    context 'when params are valid' do
      let(:form) { described_class.new(User.new) }

      it 'returns true' do
        expect(form.validate(valid_params)).to be_truthy
      end

      it 'saves user to database' do
        expect do
          form.validate(valid_params)
          form.save
        end.to change(User, :count).from(0).to(1)
      end
    end

    context 'when params are not valid' do
      let(:form) { described_class.new(User.new) }

      context 'when email is not present' do
        let(:params) { { email: '' } }

        it 'returns error message' do
          expect(form.validate(params)).to be_falsey
          expect(form.errors.details.keys.length).to be(1)
          expect(form.errors.details[:email].present?).to be_truthy
        end
      end

      context 'when email is not unique' do
        before do
          other_form = described_class.new(User.new)
          other_form.save if other_form.validate(valid_params)
        end

        it 'returns error message' do
          expect(form.validate(valid_params)).to be_falsey
          expect(form.errors.details.keys.length).to be(1)
          expect(form.errors.details[:email].present?).to be_truthy
        end
      end
    end
  end
end
