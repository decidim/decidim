# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe ManagedUserPromotionForm do
      subject { described_class.from_params(attributes) }

      let(:email) { "foo@example.org" }
      let(:attributes) do
        {
          "managed_user_promotion" => {
            "email" => email
          }
        }
      end

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      context "when email is missing" do
        let(:email) {}

        it { is_expected.to be_invalid }
      end
    end
  end
end
