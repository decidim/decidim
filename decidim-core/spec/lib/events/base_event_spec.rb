# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Events::BaseEvent do
    describe ".types" do
      subject { described_class }

      it "returns an empty array" do
        expect(subject.types).to eq []
      end
    end

    describe "notifiable?" do
      subject do
        described_class.new(
          resource: resource,
          event_name: "some.event",
          user: build(:user),
          extra: {}
        )
      end

      context "when the resource is publicable" do
        let(:resource) { build(:dummy_resource) }

        context "when it is published" do
          before do
            resource.published_at = Time.current
          end

          it { is_expected.to be_notifiable }
        end

        context "when it is not published" do
          before do
            resource.published_at = nil
          end

          it { is_expected.not_to be_notifiable }
        end
      end

      context "when there's a feature" do
        let(:resource) { build(:dummy_resource) }

        context "when it is published" do
          before do
            resource.published_at = Time.current
            resource.feature.published_at = Time.current
          end

          it { is_expected.to be_notifiable }
        end

        context "when it is not published" do
          before do
            resource.published_at = Time.current
            resource.feature.published_at = nil
          end

          it { is_expected.not_to be_notifiable }
        end
      end

      context "when there's a participatory space" do
        let(:resource) { build(:dummy_resource) }

        context "when it is published" do
          before do
            resource.published_at = Time.current
            resource.feature.participatory_space.published_at = Time.current
          end

          it { is_expected.to be_notifiable }
        end

        context "when it is not published" do
          before do
            resource.published_at = Time.current
            resource.feature.participatory_space.published_at = nil
          end

          it { is_expected.not_to be_notifiable }
        end
      end

      context "when the resource is a feature" do
        let(:resource) { build(:feature) }

        it { is_expected.to be_notifiable }

        context "when it is not published" do
          let(:resource) { build(:feature, :unpublished) }

          it { is_expected.not_to be_notifiable }
        end
      end
    end
  end
end
