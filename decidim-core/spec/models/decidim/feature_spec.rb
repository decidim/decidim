# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Feature do
    subject { feature }

    let(:feature) { build(:feature, manifest_name: "dummy") }

    it { is_expected.to be_valid }
    it { is_expected.to be_versioned }

    include_examples "publicable"

    it "overwrites the log presenter" do
      expect(described_class.log_presenter_class_for(:foo))
        .to eq Decidim::AdminLog::FeaturePresenter
    end
  end
end
