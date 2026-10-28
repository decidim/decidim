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
          app_secret: "fake-facebook-app-secret",
          icon: "phone"
        },
        twitter: {
          enabled: true,
          api_key: "fake-twitter-api-key",
          api_secret: "fake-twitter-api-secret",
          icon: "phone"
        },
        google_oauth2: {
          enabled: true,
          client_id: nil,
          client_secret: nil,
          icon: "phone"
        },
        test: {
          enabled: true,
          icon: "tools-line"
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

      it { is_expected.to match_array(scopes) }
    end

    describe "has an association for scope types" do
      subject(:organization_scopes_types) { organization.scope_types }

      let(:scope_types) { create_list(:scope_type, 2, organization:) }

      it { is_expected.to match_array(scope_types) }
    end

    describe "reciprocal associations" do
      # Default static pages cannot be destroyed, which would otherwise stop the
      # organization from being destroyed at all.
      subject(:organization) { create(:organization, create_static_pages: false) }

      let(:other_organization) { create(:organization, create_static_pages: false) }

      shared_examples "organization reciprocal association" do |association|
        it "only includes the records of its own organization" do
          expect(organization.public_send(association)).to contain_exactly(record)
        end

        it "does not include the records of another organization" do
          expect(organization.public_send(association)).not_to include(other_record)
        end

        it "destroys the records when the organization is destroyed" do
          record
          other_record

          organization.destroy

          expect(record.class.where(id: record.id)).to be_empty
          expect(other_record.class.where(id: other_record.id)).to exist
        end
      end

      context "with action logs" do
        # Participatory spaces are not cascaded through the organization associations, so the
        # participatory space is created in another organization and the organization under test
        # only contains the action log.
        let(:record) { create(:action_log, organization:, participatory_space: create(:participatory_process, organization: other_organization)) }
        let(:other_record) { create(:action_log, organization: other_organization) }

        it_behaves_like "organization reciprocal association", :action_logs
      end

      context "with content blocks" do
        let(:record) { create(:content_block, organization:) }
        let(:other_record) { create(:content_block, organization: other_organization) }

        it_behaves_like "organization reciprocal association", :content_blocks
      end

      context "with contextual help sections" do
        let(:record) { create_help_section(organization) }
        let(:other_record) { create_help_section(other_organization) }

        def create_help_section(target_organization)
          Decidim::ContextualHelpSection.create!(
            organization: target_organization,
            section_id: "section_id",
            content: { en: "Content" }
          )
        end

        it_behaves_like "organization reciprocal association", :contextual_help_sections
      end

      context "with editor images" do
        let(:record) { create(:editor_image, organization:) }
        let(:other_record) { create(:editor_image, organization: other_organization) }

        it_behaves_like "organization reciprocal association", :editor_images
      end

      context "with identities" do
        let(:record) { create(:identity, organization:, user: create(:user, organization:)) }
        let(:other_record) { create(:identity, organization: other_organization, user: create(:user, organization: other_organization)) }

        it_behaves_like "organization reciprocal association", :identities
      end

      context "with newsletters" do
        let(:record) { create(:newsletter, organization:) }
        let(:other_record) { create(:newsletter, organization: other_organization) }

        it_behaves_like "organization reciprocal association", :newsletters
      end

      context "with searchable resources" do
        let(:record) { create(:searchable_resource, organization:) }
        let(:other_record) { create(:searchable_resource, organization: other_organization) }

        it_behaves_like "organization reciprocal association", :searchable_resources
      end

      context "with share tokens" do
        let(:record) { create(:share_token, organization:) }
        let(:other_record) { create(:share_token, organization: other_organization) }

        it_behaves_like "organization reciprocal association", :share_tokens
      end

      context "with short links" do
        let(:record) { create(:short_link, organization:) }
        let(:other_record) { create(:short_link, organization: other_organization) }

        it_behaves_like "organization reciprocal association", :short_links
      end
    end

    describe "validations" do
      it "default locale should be included in available locales" do
        subject.available_locales = [:ca, :es]
        subject.default_locale = :en
        expect(subject).not_to be_valid
      end

      describe "name" do
        context "when name does not exists" do
          it "is valid" do
            expect(described_class.count).to eq(0)
            expect(subject).to be_valid
          end
        end

        context "when name exists for same locale" do
          let!(:dummy_organization) { create(:organization, name: { en: "Dummy Random 22" }) }

          it "is invalid" do
            subject.name = { en: "Dummy Random 22" }
            expect(subject).not_to be_valid
          end
        end

        context "when name exists for different locale" do
          let!(:dummy_organization) { create(:organization, name: { ca: "Dummy Random 22", en: "Dummy" }) }

          it "is invalid" do
            subject.name = { en: "Dummy Random 22" }
            expect(subject).not_to be_valid
          end
        end
      end
    end

    describe "enabled omniauth providers" do
      let!(:previous_omniauth_secrets) { Decidim.omniauth_providers }

      before do
        allow(Decidim).to receive(:omniauth_providers).and_return(omniauth_secrets)
      end

      after do
        Decidim.omniauth_providers = previous_omniauth_secrets
      end

      subject(:enabled_providers) { organization.enabled_omniauth_providers }

      context "when omniauth_settings are nil" do
        context "when providers are enabled in secrets.yml" do
          it "returns providers enabled in secrets.yml" do
            expect(enabled_providers).to eq(omniauth_secrets)
          end
        end

        context "when providers are not enabled in secrets.yml" do
          before do
            allow(Decidim).to receive(:omniauth_providers).and_return({})
          end

          it "returns no providers" do
            expect(enabled_providers).to be_empty
          end
        end
      end

      context "when it is overridden" do
        let(:organization) { create(:organization) }
        let(:omniauth_settings) do
          {
            "omniauth_settings_facebook_enabled" => true,
            "omniauth_settings_facebook_app_id" => Decidim::AttributeEncryptor.encrypt("overridden-app-id"),
            "omniauth_settings_facebook_app_secret" => Decidim::AttributeEncryptor.encrypt("overridden-app-secret"),
            "omniauth_settings_google_oauth2_enabled" => true,
            "omniauth_settings_google_oauth2_client_id" => Decidim::AttributeEncryptor.encrypt("overridden-client-id"),
            "omniauth_settings_google_oauth2_client_secret" => Decidim::AttributeEncryptor.encrypt("overridden-client-secret"),
            "omniauth_settings_twitter_enabled" => false
          }
        end

        before { organization.update!(omniauth_settings:) }

        it "returns only the enabled settings" do
          expect(subject[:facebook][:app_id]).to eq("overridden-app-id")
          expect(subject[:twitter]).to be_nil
          expect(subject[:google_oauth2][:client_id]).to eq("overridden-client-id")
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

    describe "#favicon_ico" do
      let(:favicon_path) { Decidim::Dev.asset("icon.png") }

      before do
        subject.favicon.attach(io: File.open(favicon_path), filename: File.basename(favicon_path))
        subject.save!
      end

      context "when the favicon variant has not been processed yet" do
        it "returns the processed variant" do
          expect(subject.favicon_ico).not_to be(subject.favicon)
          expect(subject.favicon_ico).to be_a(ActiveStorage::Attached::One)
          expect(subject.favicon_ico.blob).to be_a(ActiveStorage::Blob)
        end
      end

      context "when the favicon variant has been processed" do
        before { organization.attached_uploader(:favicon).variant(:favicon).processed }

        it "returns the variant" do
          expect(subject.favicon_ico).not_to be(subject.favicon)
          expect(subject.favicon_ico).to be_a(ActiveStorage::Attached::One)
          expect(subject.favicon_ico.blob).to be_a(ActiveStorage::Blob)
        end
      end
    end

    describe "favicon variants" do
      shared_context "with processed variant" do |variant_name|
        let(:variant) do
          variant = uploader.variant(variant_name)
          variant.processed.image.blob
        end

        let(:image) do
          Vips::Image.new_from_file(
            ActiveStorage::Blob.service.path_for(variant.key)
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

          it "creates the correct png variant" do
            expect(variant.content_type).to eq("image/png")
            expect(variant.filename.to_s).to eq("#{File.basename(favicon_path, ".*")}.png")
          end
        end

        context "with small variant" do
          include_context "with processed variant", :small

          it "creates the correct PNG variant" do
            expect(variant.content_type).to eq("image/png")
            expect(variant.filename.to_s).to eq("#{File.basename(favicon_path, ".*")}.png")
          end

          it "converts it the image correct dimensions" do
            expect(image.width).to eq(32)
            expect(image.height).to eq(32)
          end
        end
      end

      context "with a JPEG format" do
        let(:favicon_path) { Decidim::Dev.asset("avatar.jpg") }

        it_behaves_like "creates correct favicon variants"
      end
    end

    describe "#to_sgid" do
      subject { sgid }

      let(:organization) { create(:organization) }
      let(:sgid) { travel_to(5.years.ago) { organization.to_sgid.to_s } }

      it "does not expire" do
        located = GlobalID::Locator.locate_signed(subject)
        expect(located).to eq(organization)
      end
    end

    describe "#open_data_file_path" do
      subject(:organization) { build(:organization, host: "example.org") }

      context "without a resource" do
        it "returns the default file name" do
          expect(subject.open_data_file_path).to eq("example.org-open-data.zip")
        end
      end

      context "with a resource" do
        it "returns the file name" do
          expect(subject.open_data_file_path("proposals")).to eq("example.org-open-data-proposals.csv")
        end
      end
    end
  end
end
