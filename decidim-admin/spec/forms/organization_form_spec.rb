# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe OrganizationForm do
      subject do
        described_class.from_params(attributes).with_context(
          context
        )
      end

      let(:name) { "My super organization" }
      let(:reference_prefix) { "MSO" }
      let(:twitter_handler) { "My twitter awesome handler" }
      let(:facebook_handler) { "My facebook awesome handler" }
      let(:instagram_handler) { "My instagram awesome handler" }
      let(:youtube_handler) { "My youtube awesome handler" }
      let(:github_handler) { "My github awesome handler" }
      let(:default_locale) { :en }
      let(:organization) { create(:organization) }
      let(:attributes) do
        {
          "organization" => {
            "name" => name,
            "reference_prefix" => reference_prefix,
            "default_locale" => default_locale,
            "twitter_handler" => twitter_handler,
            "facebook_handler" => facebook_handler,
            "instagram_handler" => instagram_handler,
            "youtube_handler" => youtube_handler,
            "github_handler" => github_handler
          }
        }
      end
      let(:context) do
        {
          current_organization: organization,
          current_user: instance_double(Decidim::User).as_null_object
        }
      end

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      context "when name is missing" do
        let(:name) { nil }

        it { is_expected.to be_invalid }
      end

      context "when default_locale is missing" do
        let(:default_locale) { nil }

        it { is_expected.to be_invalid }
      end

      context "when default_locale is not an available locale" do
        let(:default_locale) { :de }

        before do
          allow(organization).to receive(:available_locales).and_return([:en, :es, :ca])
        end

        it { is_expected.to be_invalid }
      end
    end
  end
end
