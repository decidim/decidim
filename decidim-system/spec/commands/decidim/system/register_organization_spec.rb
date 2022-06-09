# frozen_string_literal: true

require "spec_helper"

module Decidim
  module System
    describe RegisterOrganization do
      describe "call" do
        let(:form) do
          RegisterOrganizationForm.new(params)
        end

        let(:command) { described_class.new(form) }

        context "when the form is valid" do
          let(:from_label) { "Decide Gotham" }
          let(:params) do
            {
              name: "Gotham City",
              host: "decide.gotham.gov",
              secondary_hosts: "foo.gotham.gov\r\n\r\nbar.gotham.gov",
              reference_prefix: "JKR",
              organization_admin_name: "Fiorello Henry La Guardia",
              organization_admin_email: "f.laguardia@gotham.gov",
              available_locales: ["en"],
              default_locale: "en",
              users_registration_mode: "enabled",
              force_users_to_authenticate_before_access_organization: "false",
              smtp_settings: {
                "address" => "mail.gotham.gov",
                "port" => "25",
                "user_name" => "f.laguardia",
                "password" => Decidim::AttributeEncryptor.encrypt("password"),
                "from_email" => "decide@gotham.gov",
                "from_label" => from_label
              },
              omniauth_settings_facebook_enabled: true,
              omniauth_settings_facebook_app_id: "facebook-app-id",
              omniauth_settings_facebook_app_secret: "facebook-app-secret",
              file_upload_settings: params_for_uploads(upload_settings)
            }
          end
          let(:upload_settings) do
            Decidim::OrganizationSettings.default(:upload)
          end

          it "returns a valid response" do
            expect { command.call }.to broadcast(:ok)
          end

          it "creates a new organization" do
            expect { command.call }.to change(Organization, :count).by(1)
            organization = Organization.last

            expect(organization.name).to eq("Gotham City")
            expect(organization.host).to eq("decide.gotham.gov")
            expect(organization.secondary_hosts).to match_array(["foo.gotham.gov", "bar.gotham.gov"])
            expect(organization.external_domain_whitelist).to match_array(["decidim.org", "github.com"])
            expect(organization.smtp_settings["from"]).to eq("Decide Gotham <decide@gotham.gov>")
            expect(organization.smtp_settings["from_email"]).to eq("decide@gotham.gov")
            expect(organization.omniauth_settings["omniauth_settings_facebook_enabled"]).to be(true)
            expect(organization.file_upload_settings).to eq(upload_settings)
            expect(
              Decidim::AttributeEncryptor.decrypt(organization.omniauth_settings["omniauth_settings_facebook_app_id"])
            ).to eq("facebook-app-id")
            expect(
              Decidim::AttributeEncryptor.decrypt(organization.omniauth_settings["omniauth_settings_facebook_app_secret"])
            ).to eq("facebook-app-secret")
          end

          it "invites a user as organization admin" do
            expect { command.call }.to change(User, :count).by(1)
            admin = User.last

            expect(admin.email).to eq("f.laguardia@gotham.gov")
            expect(admin.organization.name).to eq("Gotham City")
            expect(admin).to be_admin
            expect(admin).to be_created_by_invite
            expect(admin).to be_valid
          end

          it "sends a custom email" do
            expect do
              perform_enqueued_jobs { command.call }
            end.to change(emails, :count).by(1)
            expect(last_email_body).to include(URI.encode_www_form(["/admin"]))
          end

          it "creates the default content pages for the organization" do
            command.call
            organization = Organization.last
            expect(organization.static_pages).not_to be_empty
          end

          it "creates the default content blocks" do
            command.call
            organization = Organization.last
            expect(Decidim::ContentBlock.where(organization: organization)).to be_any
          end

          it "sets the organizations TOS version" do
            command.call
            organization = Organization.last
            tos_page = Decidim::StaticPage.find_by(slug: "terms-and-conditions", organization: organization)

            expect(organization.tos_version).not_to be_nil
            expect(organization.tos_version).to eq(tos_page.updated_at)
          end

          describe "#encrypted_smtp_settings" do
            it "concatenates from_email and from_label" do
              expect do
                perform_enqueued_jobs { command.call }
              end.to change(emails, :count).by(1)

              organization = Organization.last

              expect(organization.smtp_settings["from"]).to eq("Decide Gotham <decide@gotham.gov>")
              expect(organization.smtp_settings["from_label"]).to eq("Decide Gotham")
              expect(organization.smtp_settings["from_email"]).to eq("decide@gotham.gov")
              expect(last_email.From.value).to eq("Decide Gotham <decide@gotham.gov>")
            end

            context "when from_label is empty" do
              let(:from_label) { "" }

              it "sets the label from email" do
                expect do
                  perform_enqueued_jobs { command.call }
                end.to change(emails, :count).by(1)

                organization = Organization.last

                expect(organization.smtp_settings["from"]).to eq("decide@gotham.gov")
                expect(organization.smtp_settings["from_email"]).to eq("decide@gotham.gov")
                expect(last_email.From.value).to eq("decide@gotham.gov")
              end
            end
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

        private

        def params_for_uploads(hash)
          hash.to_h do |key, value|
            case value
            when Hash
              value = params_for_uploads(value)
            when Array
              value = value.join(",")
            end

            [key, value]
          end
        end
      end
    end
  end
end
