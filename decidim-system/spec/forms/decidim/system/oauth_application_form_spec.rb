# frozen_string_literal: true

require "spec_helper"

module Decidim
  module System
    describe OAuthApplicationForm, processing_uploads_for: Decidim::ImageUploader do
      subject do
        described_class.from_params(attributes).with_context(context)
      end

      let(:organization) { create(:organization) }
      let(:name) { "Meta Decidim" }
      let(:decidim_organization_id) { organization.id }
      let(:organization_name) { "Ajuntament de Barcelona" }
      let(:organization_url) { "http://www.barcelona.cat" }
      let(:organization_logo) do
        Decidim::Dev.test_file("city.jpeg", "image/jpeg")
      end
      let(:redirect_uri) { "https://meta.decidim.barcelona/users/auth/decidim" }
      let(:attributes) do
        {
          "oauth_application" => {
            "name" => name,
            "decidim_organization_id" => decidim_organization_id,
            "organization_name" => organization_name,
            "organization_url" => organization_url,
            "organization_logo" => organization_logo,
            "redirect_uri" => redirect_uri
          }
        }
      end
      let(:context) do
        {
          current_organization: organization,
          current_user: instance_double(Decidim::User).as_null_object
        }
      end

      context "when everything is ok" do
        it { is_expected.to be_valid }
      end

      context "when the name is missing" do
        let(:name) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when the organization id is missing" do
        let(:decidim_organization_id) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when the organization name is missing" do
        let(:organization_name) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when the organization url is missing" do
        let(:organization_url) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when the organization logo is missing" do
        let(:organization_logo) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when the redirect URI is missing" do
        let(:redirect_uri) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when the redirect uri is not https" do
        let(:redirect_uri) { "http://example.org" }

        it { is_expected.not_to be_valid }

        context "when it is localhost" do
          let(:redirect_uri) { "http://localhost:3000" }

          it { is_expected.to be_valid }
        end
      end
    end
  end
end
