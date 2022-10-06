# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe InitiativesSettings do
    subject(:initiatives_settings) { create(:initiatives_settings) }

    it { is_expected.to be_valid }

    it "overwrites the log presenter" do
      expect(described_class.log_presenter_class_for(:foo))
        .to eq Decidim::Initiatives::AdminLog::InitiativesSettingsPresenter
    end

    context "without organization" do
      before do
        initiatives_settings.organization = nil
      end

      it { is_expected.to be_invalid }
    end
  end
end
