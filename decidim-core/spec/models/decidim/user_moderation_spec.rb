# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UserModeration do
    subject { user_moderation }

    let(:user_moderation) { build(:user_moderation) }

    it { is_expected.to be_valid }
    it { is_expected.to be_versioned }

    it "overwrites the log presenter" do
      expect(described_class.log_presenter_class_for(:foo))
        .to eq Decidim::AdminLog::UserModerationPresenter
    end

    describe ".ransackable_attributes" do
      it "allows sorting by created_at" do
        expect(described_class.ransackable_attributes).to include("created_at")
      end

      it "allows sorting by report_count" do
        expect(described_class.ransackable_attributes).to include("report_count")
      end
    end
  end
end
