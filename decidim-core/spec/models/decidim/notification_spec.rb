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

    describe "with_priority scope" do
      let!(:batch_notifications) { create_list(:notification, 4) }
      let!(:now_notifications) { create_list(:notification, 4, :now_priority) }

      context "with batch priority notifications" do
        let(:priority) { :batch }

        it "returns notifications with batch priority" do
          expect(described_class.with_priority(priority)).to match_array(batch_notifications)
          expect(described_class.with_priority(priority)).not_to match_array(now_notifications)
        end
      end

      context "with now priority notifications" do
        let(:priority) { :now }

        it "returns notifications with now priority" do
          expect(described_class.with_priority(priority)).not_to match_array(batch_notifications)
          expect(described_class.with_priority(priority)).to match_array(now_notifications)
        end
      end

      context "with wrong priority" do
        let(:priority) { nil }

        it "returns nothing" do
          expect(described_class.with_priority(priority).count).to eq(0)
        end
      end
    end
  end
end
