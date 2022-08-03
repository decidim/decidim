# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Organization do
    subject(:organization) { build(:organization) }

    let(:omniauth_secrets) do
      {
        facebook: {
          enabled: true,
          app_id: "fake-facebook-app-id",
          app_secret: "fake-facebook-app-secret"
        },
        twitter: {
          enabled: true,
          api_key: "fake-twitter-api-key",
          api_secret: "fake-twitter-api-secret"
        },
        google_oauth2: {
          enabled: true,
          client_id: nil,
          client_secret: nil
        }
      }
    end

    it { is_expected.to be_valid }
    it { is_expected.to be_versioned }

    it "overwrites the log presenter" do
      expect(described_class.log_presenter_class_for(:foo))
        .to eq Decidim::AdminLog::OrganizationPresenter
    end

    describe "has an association for scopes" do
      subject(:organization_scopes) { organization.scopes }

      let(:scopes) { create_list(:scope, 2, organization:) }

      it { is_expected.to contain_exactly(*scopes) }
    end

    describe "has an association for scope types" do
      subject(:organization_scopes_types) { organization.scope_types }

      let(:scope_types) { create_list(:scope_type, 2, organization:) }

      it { is_expected.to contain_exactly(*scope_types) }
    end

    describe "validations" do
      it "default locale should be included in available locales" do
        subject.available_locales = [:ca, :es]
        subject.default_locale = :en
        expect(subject).not_to be_valid
      end
    end

    describe "enabled omniauth providers" do
      subject(:enabled_providers) { organization.enabled_omniauth_providers }

      context "when omniauth_settings are nil" do
        context "when providers are enabled in secrets.yml" do
          it "returns providers enabled in secrets.yml" do
            expect(enabled_providers).to eq(omniauth_secrets)
          end
        end

        context "when providers are not enabled in secrets.yml" do
          let!(:previous_omniauth_secrets) { Rails.application.secrets[:omniauth] }

          before do
            Rails.application.secrets[:omniauth] = nil
          end

          after do
            Rails.application.secrets[:omniauth] = previous_omniauth_secrets
          end

          it "returns no providers" do
            expect(enabled_providers).to be_empty
          end
        end
      end

      context "when it's overriden" do
        let(:organization) { create(:organization) }
        let(:omniauth_settings) do
          {
            "omniauth_settings_facebook_enabled" => true,
            "omniauth_settings_facebook_app_id" => Decidim::AttributeEncryptor.encrypt("overriden-app-id"),
            "omniauth_settings_facebook_app_secret" => Decidim::AttributeEncryptor.encrypt("overriden-app-secret"),
            "omniauth_settings_google_oauth2_enabled" => true,
            "omniauth_settings_google_oauth2_client_id" => Decidim::AttributeEncryptor.encrypt("overriden-client-id"),
            "omniauth_settings_google_oauth2_client_secret" => Decidim::AttributeEncryptor.encrypt("overriden-client-secret"),
            "omniauth_settings_twitter_enabled" => false
          }
        end

        before { organization.update!(omniauth_settings:) }

        it "returns only the enabled settings" do
          expect(subject[:facebook][:app_id]).to eq("overriden-app-id")
          expect(subject[:twitter]).to be_nil
          expect(subject[:google_oauth2][:client_id]).to eq("overriden-client-id")
        end
      end
    end

    describe "#static_pages_accessible_for" do
      it_behaves_like "accessible static pages" do
        let(:actual_page_ids) do
          organization.static_pages_accessible_for(user).pluck(:id)
        end
      end
    end

    describe "favicon variants" do
      shared_context "with processed variant" do |variant_name|
        let(:variant) do
          variant = uploader.variant(variant_name)
          variant.process
          variant.image.blob
        end

        let(:image) do
          MiniMagick::Image.open(
            ActiveStorage::Blob.service.path_for(variant.key),
            File.extname(variant.filename.to_s)
          )
        end
      end

      shared_examples "creates correct favicon variants" do
        let(:uploader) { organization.attached_uploader(:favicon) }

        before do
          organization.favicon.attach(io: File.open(favicon_path), filename: File.basename(favicon_path))
          organization.save!
        end

        context "with favicon variant" do
          include_context "with processed variant", :favicon

          let(:identified) { image.identify.split("\n") }

          it "creates the correct ICO variant" do
            expect(variant.content_type).to eq("image/vnd.microsoft.icon")
            expect(variant.filename.to_s).to eq("#{File.basename(favicon_path, ".*")}.ico")
          end

          it "converts all ICO sizes" do
            # Example output:
            #   /tmp/mini_magick20220101-123456-abcdef.ico[0] ICO 16x16 16x16+0+0 8-bit sRGB 0.020u 0:00.000
            #   /tmp/mini_magick20220101-123456-abcdef.ico[1] ICO 24x24 24x24+0+0 8-bit sRGB 0.010u 0:00.000
            #   /tmp/mini_magick20220101-123456-abcdef.ico[2] ICO 32x32 32x32+0+0 8-bit sRGB 0.000u 0:00.000
            #   /tmp/mini_magick20220101-123456-abcdef.ico[3] ICO 48x48 48x48+0+0 8-bit sRGB 0.000u 0:00.000
            #   /tmp/mini_magick20220101-123456-abcdef.ico[4] ICO 64x64 64x64+0+0 8-bit sRGB 0.000u 0:00.000
            #   /tmp/mini_magick20220101-123456-abcdef.ico[5] ICO 72x72 72x72+0+0 8-bit sRGB 0.000u 0:00.000
            #   /tmp/mini_magick20220101-123456-abcdef.ico[6] ICO 96x96 96x96+0+0 8-bit sRGB 0.000u 0:00.000
            #   /tmp/mini_magick20220101-123456-abcdef.ico[7] ICO 128x128 128x128+0+0 8-bit sRGB 0.000u 0:00.000
            #   /tmp/mini_magick20220101-123456-abcdef.ico[8] PNG 256x256 256x256+0+0 8-bit sRGB 179438B 0.000u 0:00.000
            [
              /\.ico\[0\] ICO 16x16 16x16\+0\+0 8-bit sRGB 0.[0-9]{3}u 0:[0-9]{2}\.[0-9]{3}$/,
              /\.ico\[1\] ICO 24x24 24x24\+0\+0 8-bit sRGB 0.[0-9]{3}u 0:[0-9]{2}\.[0-9]{3}$/,
              /\.ico\[2\] ICO 32x32 32x32\+0\+0 8-bit sRGB 0.[0-9]{3}u 0:[0-9]{2}\.[0-9]{3}$/,
              /\.ico\[3\] ICO 48x48 48x48\+0\+0 8-bit sRGB 0.[0-9]{3}u 0:[0-9]{2}\.[0-9]{3}$/,
              /\.ico\[4\] ICO 64x64 64x64\+0\+0 8-bit sRGB 0.[0-9]{3}u 0:[0-9]{2}\.[0-9]{3}$/,
              /\.ico\[5\] ICO 72x72 72x72\+0\+0 8-bit sRGB 0.[0-9]{3}u 0:[0-9]{2}\.[0-9]{3}$/,
              /\.ico\[6\] ICO 96x96 96x96\+0\+0 8-bit sRGB 0.[0-9]{3}u 0:[0-9]{2}\.[0-9]{3}$/,
              /\.ico\[7\] ICO 128x128 128x128\+0\+0 8-bit sRGB 0.[0-9]{3}u 0:[0-9]{2}\.[0-9]{3}$/,
              /\.ico\[8\] PNG 256x256 256x256\+0\+0 8-bit sRGB 179438B 0.[0-9]{3}u 0:[0-9]{2}\.[0-9]{3}$/
            ].each_with_index do |regexp, idx|
              expect(identified[idx]).to match(regexp)
            end
          end
        end

        context "with small variant" do
          include_context "with processed variant", :small

          it "creates the correct PNG variant" do
            expect(variant.content_type).to eq("image/png")
            expect(variant.filename.to_s).to eq("#{File.basename(favicon_path, ".*")}.png")
          end

          it "converts it the image correct dimensions" do
            expect(image.dimensions).to eq([32, 32])
          end
        end
      end

      context "with an ICO file" do
        let(:favicon_path) { Decidim::Dev.asset("icon.ico") }

        it_behaves_like "creates correct favicon variants"
      end

      context "with a PNG file" do
        let(:favicon_path) { Decidim::Dev.asset("icon.png") }

        it_behaves_like "creates correct favicon variants"
      end
    end
  end
end
