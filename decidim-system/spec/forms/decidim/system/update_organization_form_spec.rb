# frozen_string_literal: true

require "spec_helper"

module Decidim::System
  describe UpdateOrganizationForm do
    subject do
      described_class.new(
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
        omniauth_settings: {
          "omniauth_settings_facebook_enabled" => true,
          "omniauth_settings_facebook_app_id" => facebook_app_id,
          "omniauth_settings_facebook_app_secret" => facebook_app_secret
        }
      )
    end

    let(:from_label) { "Decide Gotham" }
    let(:facebook_app_id) { "plain-text-facebook-app-id" }
    let(:facebook_app_secret) { "plain-text-facebook-app-secret" }

    context "when everything is OK" do
      it { is_expected.to be_valid }

      describe "omniauth_settings" do
        it "contains attributes as plain text" do
          expect(subject.omniauth_settings_facebook_enabled).to be(true)
          expect(subject.omniauth_settings_facebook_app_id).to eq(facebook_app_id)
          expect(subject.omniauth_settings_facebook_app_secret).to eq(facebook_app_secret)
        end
      end

      describe "encrypted_omniauth_settings" do
        it "encrypts sensible attributes" do
          encrypted_settings = subject.encrypted_omniauth_settings

          expect(encrypted_settings["omniauth_settings_facebook_enabled"]).to be(true)
          expect(
            Decidim::AttributeEncryptor.decrypt(encrypted_settings["omniauth_settings_facebook_app_id"])
          ).to eq(facebook_app_id)
          expect(
            Decidim::AttributeEncryptor.decrypt(encrypted_settings["omniauth_settings_facebook_app_secret"])
          ).to eq(facebook_app_secret)
        end
      end

      describe "#set_from" do
        it "concatenates from_label and from_email" do
          from = subject.set_from

          expect(from).to eq("Decide Gotham <decide@gotham.gov>")
        end

        context "when from_label is empty" do
          let(:from_label) { "" }

          it "returns the email" do
            from = subject.set_from

            expect(from).to eq("decide@gotham.gov")
          end
        end
      end
    end
  end
end
