# frozen_string_literal: true

require "spec_helper"

module Decidim
  module System
    describe OAuthApplicationForm do
      subject do
        described_class.from_params(attributes).with_context(context)
      end

      let(:organization) { create(:organization) }
      let(:name) { "Meta Decidim" }
      let(:application_type) { "confidential" }
      let(:decidim_organization_id) { organization.id }
      let(:organization_name) { "Ajuntament de Barcelona" }
      let(:organization_url) { "http://www.barcelona.cat" }
      let(:organization_logo) do
        Decidim::Dev.test_file("city.jpeg", "image/jpeg")
      end
      let(:redirect_uri) { "https://meta.decidim.barcelona/users/auth/decidim" }
      let(:scopes) { %w(profile) }
      let(:refresh_tokens_enabled) { false }
      let(:attributes) do
        {
          "oauth_application" => {
            "name" => name,
            "application_type" => application_type,
            "decidim_organization_id" => decidim_organization_id,
            "organization_name" => organization_name,
            "organization_url" => organization_url,
            "organization_logo" => organization_logo,
            "redirect_uri" => redirect_uri,
            "scopes" => scopes,
            "refresh_tokens_enabled" => refresh_tokens_enabled
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

      context "when the application type is missing" do
        let(:application_type) { nil }

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

        context "when the application is persisted" do
          let(:oauth_application) { create(:oauth_application, organization:) }
          let(:attributes) do
            {
              "oauth_application" => oauth_application.attributes.slice(
                "id",
                "name",
                "decidim_organization_id",
                "organization_name",
                "organization_url",
                "redirect_uri",
                "refresh_tokens_enabled"
              ).merge(
                "application_type" => application_type,
                "scopes" => oauth_application.scopes.all,
                "organization_logo" => organization_logo
              )
            }
          end

          it { is_expected.to be_valid }
        end

        context "when the application is not persisted" do
          it { is_expected.not_to be_valid }
        end
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

        # Loopback address for the host machine (i.e. localhost) in Android.
        context "when it is 10.0.2.2" do
          let(:redirect_uri) { "http://10.0.2.2:3000" }

          it { is_expected.to be_valid }
        end

        context "with iOS style callback links" do
          let(:redirect_uri) { "ios-app://callback" }

          it { is_expected.not_to be_valid }

          # Public applications should be allowed iOS style callback URI
          # schemes.
          context "when the application is public" do
            let(:application_type) { "public" }

            it { is_expected.to be_valid }

            context "and the redirect URI scheme is http" do
              let(:redirect_uri) { "http://example.org" }

              it { is_expected.not_to be_valid }
            end
          end
        end
      end

      context "with all the valid scopes" do
        let(:scopes) { %w(profile user api:read api:write) }

        it { is_expected.to be_valid }
      end

      context "with one invalid scope" do
        let(:scopes) { %w(profile foobar) }

        it { is_expected.not_to be_valid }
      end
    end
  end
end
