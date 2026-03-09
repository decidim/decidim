# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe ContentBlockForm do
      subject { form }

      let(:organization) { create(:organization) }
      let(:manifest) do
        Decidim::ContentBlockManifest.new.tap do |manifest|
          manifest.name = :test_block
          manifest.cell = "decidim/content_blocks/test_block"
          manifest.public_name_key = "decidim.content_blocks.test_block.name"
          manifest.settings do |settings|
            settings.attribute :test_text, type: :text, translated: true, editor: true, required: true
          end
        end
      end

      let(:content_block) do
        block = create(:content_block, organization:, scope_name: :homepage)
        # Override the manifest lookup to use our test manifest
        allow(block).to receive(:manifest).and_return(manifest)
        allow(block).to receive(:manifest_name).and_return(:test_block)
        block
      end

      let(:test_settings) do
        {
          "test_text_ca" => "",
          "test_text_en" => "Test text en",
          "test_text_es" => ""
        }
      end

      let(:params) do
        {
          "settings" => test_settings,
          "images" => {}
        }
      end

      let(:form) do
        described_class.from_params(params).with_context(
          current_organization: organization,
          content_block:
        )
      end

      context "when everything is ok" do
        it { is_expected.to be_valid }
      end

      context "when a settings required attribute is missing in the default locale" do
        let(:test_settings) do
          {
            "test_text_ca" => "Test text ca",
            "test_text_en" => "",
            "test_text_es" => "Test text es"
          }
        end

        it { is_expected.not_to be_valid }

        it "adds errors to the settings attribute" do
          form.valid?
          expect(form.errors[:settings]).to include(/cannot be blank/)
        end
      end

      context "when only non-default locale has content" do
        let(:test_settings) do
          {
            "test_text_ca" => "Test text ca",
            "test_text_en" => "",
            "test_text_es" => ""
          }
        end

        it { is_expected.not_to be_valid }
      end

      context "when settings is empty" do
        let(:test_settings) { {} }

        it { is_expected.not_to be_valid }
      end

      describe "#settings?" do
        it "returns true when settings has attributes" do
          form.valid? # Trigger coercion
          expect(form.settings?).to be true
        end

        context "when settings has no attributes" do
          let(:manifest) do
            Decidim::ContentBlockManifest.new.tap do |manifest|
              manifest.name = :test_block
              manifest.cell = "decidim/content_blocks/test_block"
              manifest.public_name_key = "decidim.content_blocks.test_block.name"
            end
          end

          it "returns false" do
            form.valid? # Trigger coercion
            expect(form.settings?).to be false
          end
        end
      end

      describe "coerce_settings" do
        it "coerces settings to a schema object with default_locale" do
          form.valid?
          expect(form.settings).to respond_to(:valid?)
          expect(form.settings.default_locale).to eq(organization.default_locale)
        end
      end
    end
  end
end
