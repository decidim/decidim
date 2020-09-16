# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Notification do
    subject { notification }

    let(:notification) { build(:notification) }

    it { is_expected.to be_valid }

    describe "validations" do
      context "without user" do
        let(:notification) { build(:notification, user: nil) }

        it { is_expected.not_to be_valid }
      end

      context "without resource" do
        let(:notification) { build(:notification, resource: nil) }

        it { is_expected.not_to be_valid }
      end
    end

    describe "priority_level scope" do
      let!(:low_notifications) { create_list(:notification, 4, :low_priority) }
      let!(:high_notifications) { create_list(:notification, 4, :high_priority) }

      context "with low priority notifications" do
        let(:priority_level) { :low }

        it "returns notifications with low priority" do
          expect(described_class.priority_level(priority_level)).to match_array(low_notifications)
          expect(described_class.priority_level(priority_level)).not_to match_array(high_notifications)
        end
      end

      context "with low priority notifications" do
        let(:priority_level) { :high }

        it "returns notifications with low priority" do
          expect(described_class.priority_level(priority_level)).not_to match_array(low_notifications)
          expect(described_class.priority_level(priority_level)).to match_array(high_notifications)
        end
      end

      context "with wrong priority" do
        let(:priority_level) { nil }

        it "returns nothing" do
          expect(described_class.priority_level(priority_level).count).to eq(0)
        end
      end
    end
  end
end
