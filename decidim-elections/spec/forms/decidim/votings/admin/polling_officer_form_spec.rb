# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Votings
    module Admin
      describe PollingOfficerForm do
        subject(:form) { described_class.from_params(attributes) }

        let(:name) { ::Faker::Name.name }
        let(:email) { ::Faker::Internet.email }
        let(:attributes) do
          {
            name: name,
            email: email
          }
        end

        it { is_expected.to be_valid }

        describe "when email is invalid" do
          let(:email) { "invalid#email.org" }

          it { is_expected.not_to be_valid }
        end

        describe "when email is missing" do
          let(:email) { nil }

          it { is_expected.not_to be_valid }
        end

        describe "when name is invalid" do
          let(:name) { "Miao<121" }

          it { is_expected.not_to be_valid }
        end

        describe "when name is missing" do
          let(:name) { nil }

          it { is_expected.not_to be_valid }
        end
      end
    end
  end
end
