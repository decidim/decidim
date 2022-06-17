# frozen_string_literal: true

require "spec_helper"

describe PasswordValidator do
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
        errors:
      )
    end
    let(:attribute) { "password" }
    let(:options) do
      {
        attributes: [attribute]
      }
    end

    describe "perfect password" do
      let(:value) { "decidim123456" }

      it "just works" do
        expect(validator).to be(true)
        expect(record.errors[attribute]).to be_empty
      end
    end

    context "when there is blacklisted passwords" do
      let(:example_password) { "examplepassword123456" }

      before do
        allow(Decidim).to receive(:password_blacklist).and_return(
          [
            example_password,
            /[a-z]*foobar\w*/
          ]
        )
      end

      describe "example password" do
        let(:value) { example_password }

        it "is blacklisted" do
          expect(validator).to be(false)
          expect(record.errors[attribute]).to eq(["is blacklisted"])
        end
      end

      describe "regex blacklist" do
        let(:value) { "bazfoobar123456" }

        it "does not validate" do
          expect(validator).to be(false)
          expect(record.errors[attribute]).to eq(["is blacklisted"])
        end
      end

      describe "still accepts other passwords" do
        let(:value) { "decidim123456" }

        it "is valid" do
          expect(validator).to be(true)
          expect(record.errors[attribute]).to be_empty
        end
      end
    end

    describe "short password" do
      let(:value) { ::Faker::Internet.password(max_length: ::PasswordValidator::MINIMUM_LENGTH - 1) }

      it "is too short" do
        expect(validator).to be(false)
        expect(record.errors[attribute]).to eq(["is too short"])
      end
    end

    describe "long password" do
      let(:value) { ::Faker::Internet.password(min_length: ::PasswordValidator::MAX_LENGTH + 1) }

      it "is too long" do
        expect(validator).to be(false)
        expect(record.errors[attribute]).to eq(["is too long"])
      end
    end

    describe "simple password" do
      let(:value) { "ab" * ::PasswordValidator::MINIMUM_LENGTH }

      it "does not have enough unique characters" do
        expect(validator).to be(false)
        expect(record.errors[attribute]).to eq(["does not have enough unique characters"])
      end
    end

    describe "email included in password" do
      let(:value) { "foo#{record.email}bar" }

      it "is too similar with email" do
        expect(validator).to be(false)
        expect(record.errors[attribute]).to eq(["is too similar to your email"])
      end
    end

    describe "name included in password" do
      let(:value) { "foo#{record.name.delete(" ")}bar" }

      it "is too similar with name" do
        expect(validator).to be(false)
        expect(record.errors[attribute]).to eq(["is too similar to your name"])
      end
    end

    describe "nickname included in password" do
      let(:value) { "foo#{record.nickname}bar" }

      it "is too similar with nickname" do
        expect(validator).to be(false)
        expect(record.errors[attribute]).to eq(["is too similar to your nickname"])
      end
    end

    describe "organization host included in password" do
      let(:value) { "foo#{organization.host}bar" }

      it "is too similar with domain" do
        expect(validator).to be(false)
        expect(record.errors[attribute]).to eq(["is too similar to this domain name"])
      end
    end

    describe "common password" do
      let(:value) { "qwerty12345" }

      it "is too common" do
        expect(validator).to be(false)
        expect(record.errors[attribute]).to eq(["is too common"])
      end
    end
  end
end
