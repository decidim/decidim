# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Moderation do
    subject { moderation }

    let(:moderation) { build(:moderation) }

    it { is_expected.to be_valid }
    it { is_expected.to be_versioned }

    it "overwrites the log presenter" do
      expect(described_class.log_presenter_class_for(:foo))
        .to eq Decidim::AdminLog::ModerationPresenter
    end
  end
end
