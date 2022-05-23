# frozen_string_literal: true

require "spec_helper"

describe AdminPasswordValidator do
  describe "#validate_each" do
    let(:organization) { create(:organization) }
    let(:validator) { described_class.new(options).validate_each(record, attribute, value) }

    let(:errors) { ActiveModel::Errors.new(attribute.to_s => []) }
    let(:record) do
      double(
        name: ::Faker::Name.name,
        email: ::Faker::Internet.email,
        nickname: ::Faker::Internet.username(specifier: 10..15),
        current_organization: organization,
        errors: errors,
        admin: true,
        previous_passwords: previous_passwords,
        encrypted_password_was: ::Devise::Encryptor.digest(Decidim::User, "decidim123456")
      )
    end
    let(:attribute) { "password" }
    let(:options) do
      {
        attributes: [attribute]
      }
    end
    let(:previous_passwords) { [] }

    describe "perfect password" do
      let(:value) { "decidim123456789" }

      it "just works" do
        expect(validator).to be(true)
        expect(record.errors[attribute]).to be_empty
      end
    end

    describe "short password" do
      let(:value) { ::Faker::Internet.password(max_length: ::AdminPasswordValidator::MINIMUM_LENGTH - 1) }

      it "is too short" do
        expect(validator).to be(false)
        expect(record.errors[attribute]).to eq(["is too short"])
      end
    end

    describe "repeated password" do
      let(:previous_passwords) { plain_passwords.map { |password| ::Devise::Encryptor.digest(Decidim::User, password) } }
      let(:plain_passwords) { Array.new(6) { ::Faker::Internet.password(min_length: ::AdminPasswordValidator::MINIMUM_LENGTH) } }

      context "when password is last used" do
        let(:value) { plain_passwords[0] }

        it "cant reuse" do
          expect(validator).to be(false)
          expect(record.errors[attribute]).to eq(["can't reuse old password"])
        end
      end

      context "when password has used before" do
        let(:value) { plain_passwords[2] }

        it "cant reuse" do
          expect(validator).to be(false)
          expect(record.errors[attribute]).to eq(["can't reuse old password"])
        end
      end

      context "when password is used but repetition times is less" do
        let(:value) { plain_passwords[5] }

        it "can reuse" do
          expect(validator).to be(true)
          expect(record.errors[attribute]).to be_empty
        end
      end
    end
  end
end
