# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Conferences
    module Admin
      describe DiplomaForm do
        subject(:form) { described_class.from_params(attributes).with_context(context) }

        let(:organization) { create :organization }
        let(:context) do
          {
            current_organization: organization
          }
        end

        let(:signature_name) { "Signature Name" }
        let(:main_logo) { Decidim::Dev.test_file("avatar.jpg", "image/jpeg") }
        let(:signature) { Decidim::Dev.test_file("avatar.jpg", "image/jpeg") }
        let(:sign_date) { 5.days.from_now }
        let(:attributes) do
          {
            "conference" => {
              "signature_name" => signature_name,
              "main_logo" => main_logo,
              "signature" => signature,
              "sign_date" => sign_date
            }
          }
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when signature_name is missing" do
          let(:signature_name) { nil }

          it { is_expected.to be_invalid }
        end

        context "when sign_date is missing" do
          let(:sign_date) { nil }

          it { is_expected.to be_invalid }
        end

        context "when main logo is missing" do
          let(:main_logo) { nil }

          it { is_expected.to be_invalid }
        end

        context "when signature is missing" do
          let(:signature) { nil }

          it { is_expected.to be_invalid }
        end
      end
    end
  end
end
