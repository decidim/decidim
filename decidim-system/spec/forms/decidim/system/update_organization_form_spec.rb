# frozen_string_literal: true

require "spec_helper"

module Decidim::System
  describe UpdateOrganizationForm do
    subject do
      described_class.new(
        name: { ca: "", en: "Gotham City", es: "" },
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

    describe "validations" do
      describe "organization name presence" do
        let(:organization) { create(:organization, default_locale: "en") }

        before do
          subject.id = organization.id
          allow(subject).to receive(:current_organization).and_return(organization)
        end

        context "when name in default locale is present" do
          before { subject.name = { en: "Gotham City" } }

          it { is_expected.to be_valid }
        end

        context "when name in default locale is blank" do
          before { subject.name = { en: "" } }

          it { is_expected.not_to be_valid }

          it "adds an error to the default locale name attribute" do
            subject.valid?
            expect(subject.errors[:name_en]).to include("cannot be blank")
          end
        end

        context "when organization has different default locale" do
          let(:organization) { create(:organization, default_locale: "es") }

          before do
            subject.default_locale = "es"
            subject.name = { es: "" }
          end

          it { is_expected.not_to be_valid }

          it "adds an error to the correct locale name attribute" do
            subject.valid?
            expect(subject.errors[:name_es]).to include("cannot be blank")
          end
        end

        context "when current_organization is not set" do
          before do
            allow(subject).to receive(:current_organization).and_return(nil)
            subject.send(:"name_#{Decidim.default_locale}=", "")
          end

          it { is_expected.not_to be_valid }

          it "uses Decidim default locale" do
            subject.valid?
            expect(subject.errors[:"name_#{Decidim.default_locale}"]).to include("cannot be blank")
          end
        end
      end

      describe "host format" do
        context "when host contains spaces" do
          before { subject.host = "example .org" }

          it { is_expected.not_to be_valid }

          it "adds an error" do
            subject.valid?
            expect(subject.errors[:host]).to include("is invalid")
          end
        end

        context "when host has leading space" do
          before { subject.host = " example.org" }

          it { is_expected.not_to be_valid }

          it "adds an error" do
            subject.valid?
            expect(subject.errors[:host]).to include("is invalid")
          end
        end

        context "when host has trailing space" do
          before { subject.host = "example.org " }

          it { is_expected.not_to be_valid }

          it "adds an error" do
            subject.valid?
            expect(subject.errors[:host]).to include("is invalid")
          end
        end

        context "when host has special characters" do
          before { subject.host = "example@org!" }

          it { is_expected.not_to be_valid }

          it "adds an error" do
            subject.valid?
            expect(subject.errors[:host]).to include("is invalid")
          end
        end

        context "when host has leading hyphen" do
          before { subject.host = "-example.org" }

          it { is_expected.not_to be_valid }

          it "adds an error" do
            subject.valid?
            expect(subject.errors[:host]).to include("is invalid")
          end
        end

        context "when host has trailing hyphen" do
          before { subject.host = "example-.org" }

          it { is_expected.not_to be_valid }

          it "adds an error" do
            subject.valid?
            expect(subject.errors[:host]).to include("is invalid")
          end
        end

        context "when host is localhost" do
          before { subject.host = "localhost" }

          it { is_expected.not_to be_valid }
        end

        context "when host is a single-label hostname in development" do
          before do
            allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("development"))
            subject.host = "localhost"
          end

          it { is_expected.to be_valid }
        end

        context "when host is valid simple domain" do
          before { subject.host = "example.org" }

          it { is_expected.to be_valid }
        end

        context "when host is valid subdomain" do
          before { subject.host = "sub.example.org" }

          it { is_expected.to be_valid }
        end

        context "when host is valid multi-level subdomain" do
          before { subject.host = "my-site.example.org" }

          it { is_expected.to be_valid }
        end

        context "when host is valid IPv4" do
          before { subject.host = "127.0.0.1" }

          it { is_expected.to be_valid }
        end

        context "when host is valid IPv4 full" do
          before { subject.host = "192.168.1.1" }

          it { is_expected.to be_valid }
        end

        context "when host is valid IPv4 max value" do
          before { subject.host = "255.255.255.255" }

          it { is_expected.to be_valid }
        end

        context "when host is invalid IPv4 octet > 255" do
          before { subject.host = "256.0.0.1" }

          it { is_expected.not_to be_valid }

          it "adds an error" do
            subject.valid?
            expect(subject.errors[:host]).to include("is invalid")
          end
        end

        context "when host is valid IPv6 loopback" do
          before { subject.host = "::1" }

          it { is_expected.to be_valid }
        end

        context "when host is valid IPv6 bracketed" do
          before { subject.host = "[::1]" }

          it { is_expected.to be_valid }
        end

        context "when host is valid IPv6 full" do
          before { subject.host = "2001:db8::1" }

          it { is_expected.to be_valid }
        end

        context "when host is valid IPv6 standard" do
          before { subject.host = "fe80:0:0:0:1:0:0:1" }

          it { is_expected.to be_valid }
        end
      end

      describe "secondary_hosts format" do
        context "when secondary_hosts contains spaces" do
          before { subject.secondary_hosts = "example .org" }

          it { is_expected.not_to be_valid }

          it "adds an error" do
            subject.valid?
            expect(subject.errors[:secondary_hosts]).to include("is invalid")
          end
        end

        context "when secondary_hosts has special characters" do
          before { subject.secondary_hosts = "example@org!" }

          it { is_expected.not_to be_valid }

          it "adds an error" do
            subject.valid?
            expect(subject.errors[:secondary_hosts]).to include("is invalid")
          end
        end

        context "when one of multiple secondary_hosts is invalid" do
          before { subject.secondary_hosts = "valid.example.org\ninvalid .host" }

          it { is_expected.not_to be_valid }

          it "adds an error" do
            subject.valid?
            expect(subject.errors[:secondary_hosts]).to include("is invalid")
          end
        end

        context "when secondary_hosts is valid simple domain" do
          before { subject.secondary_hosts = "example.org" }

          it { is_expected.to be_valid }
        end

        context "when secondary_hosts is localhost" do
          before { subject.secondary_hosts = "localhost" }

          it { is_expected.not_to be_valid }
        end

        context "when secondary_hosts is a single-label hostname in development" do
          before do
            allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("development"))
            subject.secondary_hosts = "localhost"
          end

          it { is_expected.to be_valid }
        end

        context "when secondary_hosts is valid IPv4" do
          before { subject.secondary_hosts = "127.0.0.1" }

          it { is_expected.to be_valid }
        end

        context "when secondary_hosts has multiple valid hosts" do
          before { subject.secondary_hosts = "foo.example.org\nbar.example.org" }

          it { is_expected.to be_valid }
        end

        context "when secondary_hosts has empty lines" do
          before { subject.secondary_hosts = "foo.example.org\r\n\r\nbar.example.org" }

          it { is_expected.to be_valid }
        end
      end

      describe "organization uniqueness" do
        let!(:existing_organization) do
          create(
            :organization,
            name: { en: "Existing City", es: "Ciudad Existente" },
            host: "existing.example.org"
          )
        end

        context "when creating a new organization" do
          context "when organization name already exists (case-insensitive)" do
            before { subject.name_en = "EXISTING CITY" }

            it { is_expected.not_to be_valid }

            it "adds an error to the name attribute" do
              subject.valid?
              expect(subject.errors[:name_en]).to include("has already been taken")
            end
          end

          context "when organization name already exists in different locale" do
            before { subject.name_en = "Ciudad Existente" }

            it { is_expected.not_to be_valid }

            it "adds an error" do
              subject.valid?
              expect(subject.errors[:name_en]).to include("has already been taken")
            end
          end

          context "when multiple locale names conflict" do
            before do
              subject.name_en = "Existing City"
              subject.name_es = "Ciudad Existente"
            end

            it { is_expected.not_to be_valid }

            it "adds errors to both locale attributes" do
              subject.valid?
              expect(subject.errors[:name_en]).to include("has already been taken")
              expect(subject.errors[:name_es]).to include("has already been taken")
            end
          end

          context "when host already exists" do
            before { subject.host = "existing.example.org" }

            it { is_expected.not_to be_valid }

            it "adds an error" do
              subject.valid?
              expect(subject.errors[:host]).to include("has already been taken")
            end
          end

          context "when organization name is unique" do
            before { subject.name_en = "Unique City" }

            it { is_expected.to be_valid }
          end

          context "when host is unique" do
            before { subject.host = "unique.example.org" }

            it { is_expected.to be_valid }
          end
        end

        context "when updating an existing organization" do
          let(:organization_to_update) do
            create(
              :organization,
              name: { en: "My City", es: "Mi Ciudad" },
              host: "mycity.example.org"
            )
          end

          before do
            subject.id = organization_to_update.id
          end

          context "when keeping the same name" do
            before { subject.name_en = "My City" }

            it { is_expected.to be_valid }
          end

          context "when keeping the same host" do
            before { subject.host = "mycity.example.org" }

            it { is_expected.to be_valid }
          end

          context "when changing name to an existing one" do
            before { subject.name_en = "Existing City" }

            it { is_expected.not_to be_valid }

            it "adds an error" do
              subject.valid?
              expect(subject.errors[:name_en]).to include("has already been taken")
            end
          end

          context "when changing host to an existing one" do
            before { subject.host = "existing.example.org" }

            it { is_expected.not_to be_valid }

            it "adds an error" do
              subject.valid?
              expect(subject.errors[:host]).to include("has already been taken")
            end
          end

          context "when changing name to a unique one" do
            before { subject.name_en = "Brand New City" }

            it { is_expected.to be_valid }
          end

          context "when changing host to a unique one" do
            before { subject.host = "other.example.org" }

            it { is_expected.to be_valid }
          end
        end

        context "when name contains machine_translations" do
          let!(:org_with_translations) do
            create(
              :organization,
              name: {
                :en => "City",
                "machine_translations" => { fr: "Ville" }
              }
            )
          end

          context "when new name conflicts with machine translation" do
            before { subject.name_en = "Ville" }

            it { is_expected.not_to be_valid }

            it "adds an error" do
              subject.valid?
              expect(subject.errors[:name_en]).to include("has already been taken")
            end
          end
        end

        context "when name value is a Hash (nested structure)" do
          before do
            allow(subject).to receive(:name).and_return({ en: { nested: "value" }, es: "Valid Name" })
          end

          it "skips Hash values during validation" do
            expect { subject.valid? }.not_to raise_error
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
              default: %w(jpg jpeg),
              admin: %w(jpg jpeg png),
              image: %w(jpg jpeg png)
            },
            allowed_content_types: {
              default: %w(image/*),
              admin: %w(image/*)
            },
            maximum_file_size: {
              default: 7.2,
              avatar: 2.4
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
