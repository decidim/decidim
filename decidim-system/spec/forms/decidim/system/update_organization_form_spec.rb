# frozen_string_literal: true

require "spec_helper"

module Decidim::System
  describe UpdateOrganizationForm do
    subject do
      described_class.new(
        name: "Gotham City",
        host: "decide.example.org",
        secondary_hosts: "foo.example.org\r\n\r\nbar.example.org",
        reference_prefix: "JKR",
        organization_admin_name: "Fiorello Henry La Guardia",
        organization_admin_email: "f.laguardia@example.org",
        available_locales: ["en"],
        default_locale: "en",
        users_registration_mode: "enabled",
        force_users_to_authenticate_before_access_organization: "false",
        **smtp_settings,
        **omniauth_settings
      )
    end
    let(:omniauth_settings) do
      {
        "omniauth_settings_facebook_enabled" => true,
        "omniauth_settings_facebook_app_id" => facebook_app_id,
        "omniauth_settings_facebook_app_secret" => facebook_app_secret
      }
    end
    let(:smtp_settings) do
      {
        "address" => "mail.example.org",
        "port" => 25,
        "user_name" => "f.laguardia",
        "password" => password,
        "from_email" => "decide@example.org",
        "from_label" => from_label
      }
    end
    let(:password) { "secret_password" }
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

        context "when all values are blank" do
          let(:omniauth_settings) do
            {
              "omniauth_settings_facebook_enabled" => nil,
              "omniauth_settings_facebook_app_id" => nil,
              "omniauth_settings_facebook_app_secret" => nil
            }
          end

          it "returns nil" do
            expect(subject.encrypted_omniauth_settings).to be_nil
          end
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

          expect(from).to eq("Decide Gotham <decide@example.org>")
        end

        context "when from_label is empty" do
          let(:from_label) { "" }

          it "returns the email" do
            from = subject.set_from

            expect(from).to eq("decide@example.org")
          end
        end
      end

      describe "smtp_settings" do
        it "handles SMTP password properly" do
          expect(subject.smtp_settings).to eq(smtp_settings.except("password"))
          expect(Decidim::AttributeEncryptor.decrypt(subject.encrypted_smtp_settings[:encrypted_password])).to eq(password)
        end

        context "when all values are blank" do
          let(:smtp_settings) do
            {
              "address" => "",
              "port" => "",
              "user_name" => "",
              "password" => "",
              "from_email" => "",
              "from_label" => ""
            }
          end

          it "returns nil" do
            expect(subject.encrypted_smtp_settings).to be_nil
          end
        end
      end
    end

    describe "#map_model" do
      subject { described_class.from_model(organization) }

      let(:organization) do
        create(
          :organization,
          secondary_hosts: ["foobar.example.org", "foobaz.example.org"],
          omniauth_settings: {
            omniauth_settings_facebook_enabled: Decidim::AttributeEncryptor.encrypt(true),
            omniauth_settings_facebook_app_id: Decidim::AttributeEncryptor.encrypt("foo")
          },
          file_upload_settings: {
            allowed_file_extensions: {
              "default" => %w(jpg jpeg),
              "admin" => %w(jpg jpeg png),
              "image" => %w(jpg jpeg png)
            },
            "allowed_content_types" => {
              "default" => %w(image/*),
              "admin" => %w(image/*)
            },
            "maximum_file_size" => {
              "default" => 7.2,
              "avatar" => 2.4
            }
          }
        )
      end

      it "maps the organization attributes correctly" do
        expect(subject.secondary_hosts).to eq(organization.secondary_hosts.join("\n"))
        expect(subject.omniauth_settings).to eq(
          {
            "omniauth_settings_facebook_app_id" => "foo",
            "omniauth_settings_facebook_enabled" => true
          }
        )
        expect(subject.file_upload_settings.final).to eq(
          {
            allowed_content_types: { "admin" => %w(image/*), "default" => %w(image/*) },
            allowed_file_extensions: { "admin" => %w(jpg jpeg png), "default" => %w(jpg jpeg), "image" => %w(jpg jpeg png) },
            maximum_file_size: { "avatar" => 2.4, "default" => 7.2 }
          }
        )
      end
    end
  end
end
