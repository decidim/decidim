# frozen_string_literal: true

require "spec_helper"

module Decidim
  module System
    describe UpdateOrganization do
      describe "call" do
        let(:form) do
          UpdateOrganizationForm.new(params)
        end
        let(:organization) { create :organization, name: "My organization" }

        let(:command) { described_class.new(organization.id, form) }

        context "when the form is valid" do
          let(:params) do
            {
              name: "Gotham City",
              host: "decide.gotham.gov",
              secondary_hosts: "foo.gotham.gov\r\n\r\nbar.gotham.gov",
              force_users_to_authenticate_before_access_organization: false,
              users_registration_mode: "existing",
              omniauth_settings_facebook_enabled: true,
              omniauth_settings_facebook_app_id: "facebook-app-id",
              omniauth_settings_facebook_app_secret: "facebook-app-secret"
            }
          end

          it "returns a valid response" do
            expect { command.call }.to broadcast(:ok)
          end

          it "updates the organization" do
            expect { command.call }.to change(Organization, :count).by(1)
            organization = Organization.last

            expect(organization.name).to eq("Gotham City")
            expect(organization.host).to eq("decide.gotham.gov")
            expect(organization.secondary_hosts).to match_array(["foo.gotham.gov", "bar.gotham.gov"])
            expect(organization.users_registration_mode).to eq("existing")

            expect(organization.omniauth_settings["omniauth_settings_facebook_enabled"]).to eq(true)
            expect(
              Decidim::AttributeEncryptor.decrypt(organization.omniauth_settings["omniauth_settings_facebook_app_id"])
            ).to eq("facebook-app-id")
            expect(
              Decidim::AttributeEncryptor.decrypt(organization.omniauth_settings["omniauth_settings_facebook_app_secret"])
            ).to eq("facebook-app-secret")
          end
        end

        context "when the form is invalid" do
          let(:params) do
            {
              name: nil,
              host: "foo.com"
            }
          end

          it "returns an invalid response" do
            expect { command.call }.to broadcast(:invalid)
          end
        end
      end
    end
  end
end
