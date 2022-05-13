# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Conferences
    module Admin
      describe PartnerForm do
        subject(:form) { described_class.from_params(attributes).with_context(context) }

        let(:organization) { create :organization }
        let(:context) do
          {
            current_organization: organization
          }
        end

        let(:name) { "Name" }
        let(:weight) { 1 }
        let(:link) { "http://decidim.org" }
        let(:logo) { upload_test_file(Decidim::Dev.test_file("avatar.jpg", "image/jpeg")) }
        let(:partner_type) { "main_promotor" }
        let(:attributes) do
          {
            "conference_partner" => {
              "name" => name,
              "weight" => weight,
              "link" => link,
              "logo" => logo,
              "partner_type" => partner_type
            }
          }
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when name is missing" do
          let(:name) { nil }

          it { is_expected.to be_invalid }
        end

        context "when logo is missing" do
          let(:logo) { nil }

          it { is_expected.to be_invalid }
        end

        context "when weight is missing" do
          let(:weight) { nil }

          it { is_expected.to be_invalid }
        end

        context "when partner type is missing" do
          let(:partner_type) { nil }

          it { is_expected.to be_invalid }
        end
      end
    end
  end
end
