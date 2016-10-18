# frozen_string_literal: true
require "spec_helper"

module Decidim
  describe ParticipatoryProcessStep do
    let(:participatory_process_step) { build(:participatory_process_step) }

    subject { participatory_process_step }

    it { is_expected.to be_valid }

    context "when start date is after end date" do
      let(:participatory_process_step) do
        build(:participatory_process_step, start_date: 2.months.from_now, end_date: 1.month.ago)
      end

      it { is_expected.to_not be_valid }

      it "has an error in end_date" do
        subject.valid?

        expect(subject.errors[:end_date]).to_not be_empty
      end
    end

    context "when start_date is present" do
      let(:start_date) { 1.month.from_now }

      it { is_expected.to be_valid }
    end

    context "when end_date is present" do
      let(:end_date) { 2.months.ago }

      it { is_expected.to be_valid }
    end
  end
end
