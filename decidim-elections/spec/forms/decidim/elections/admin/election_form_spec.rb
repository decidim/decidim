# frozen_string_literal: true

require "spec_helper"

module Decidim::Elections
  describe Admin::ElectionForm do
    subject { described_class.from_params(attributes).with_context(context) }

    let(:organization) { create(:organization) }
    let(:component) { create(:elections_component, organization:) }
    let(:context) do
      {
        current_organization: organization,
        current_component: component
      }
    end

    let(:start_at) { 1.day.from_now }
    let(:end_at) { 2.days.from_now }
    let(:manual_start) { false }
    let(:results_availability) { "real_time" }

    let(:attributes) do
      {
        title_en: "Title",
        description_en: "Description",
        start_at:,
        end_at:,
        manual_start:,
        results_availability:
      }
    end

    it { is_expected.to be_valid }

    describe "when title is missing" do
      let(:attributes) { super().merge(title_en: nil) }

      it { is_expected.not_to be_valid }
    end

    describe "when description is missing" do
      let(:attributes) { super().merge(description_en: nil) }

      it { is_expected.to be_valid }
    end

    describe "when end_at is missing" do
      let(:end_at) { nil }

      it { is_expected.not_to be_valid }
    end

    describe "when start_at is after end_at" do
      let(:start_at) { end_at + 1.day }

      it { is_expected.not_to be_valid }
    end

    describe "when start_at equals end_at" do
      let(:start_at) { end_at }

      it { is_expected.not_to be_valid }
    end

    describe "when manual_start is true and end_at is in the past" do
      let(:manual_start) { true }
      let(:end_at) { 1.hour.ago }

      it { is_expected.not_to be_valid }
    end

    describe "when results_availability is invalid" do
      let(:results_availability) { "invalid_value" }

      it { is_expected.not_to be_valid }
    end

    describe "when results_availability is missing" do
      let(:results_availability) { nil }

      it { is_expected.not_to be_valid }
    end

    describe "when manual_start is true and end_at is missing" do
      let(:manual_start) { true }
      let(:end_at) { nil }

      it { is_expected.not_to be_valid }
    end

    describe "when results_availability is per_question" do
      let(:results_availability) { "per_question" }

      context "and manual_start is true" do
        let(:manual_start) { true }

        it { is_expected.to be_valid }
      end

      context "and manual_start is false" do
        let(:manual_start) { false }

        it { is_expected.not_to be_valid }
      end
    end

    describe "when results_availability is real_time" do
      let(:results_availability) { "real_time" }

      context "and manual_start is true" do
        let(:manual_start) { true }

        it { is_expected.not_to be_valid }
      end

      context "and manual_start is false" do
        let(:manual_start) { false }

        it { is_expected.to be_valid }
      end
    end

    describe "#results_availability_labels" do
      let(:form) { described_class.from_params(attributes).with_context(context) }

      it "returns available labels with i18n keys" do
        expect(form.results_availability_labels).to all(satisfy { |(value, label)| value.is_a?(String) && label.is_a?(String) })
      end
    end

    describe "#map_model" do
      let(:form) { described_class.new.with_context(context) }
      let(:election) { build(:election, start_at: nil) }

      it "sets manual_start to true if start_at is nil" do
        form.map_model(election)
        expect(form.manual_start).to be true
      end
    end
  end
end
