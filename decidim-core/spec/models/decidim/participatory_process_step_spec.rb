# frozen_string_literal: true
require "spec_helper"

module Decidim
  describe ParticipatoryProcessStep do
    let(:participatory_process_step) { build(:participatory_process_step, position: position) }
    let(:position) { nil }

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

    context "active" do
      context "when there's an active step in the same process" do
        let(:active_step) { create :participatory_process_step, :active }
        let(:participatory_process_step) do
          build(:participatory_process_step, :active, participatory_process: active_step.participatory_process)
        end

        it { is_expected.to_not be_valid }
      end

      context "with multiple inactive steps" do
        let(:inactive_step) { create :participatory_process_step }
        let(:participatory_process_step) do
          build(:participatory_process_step, participatory_process: inactive_step.participatory_process)
        end

        it { is_expected.to be_valid }
      end
    end

    context "position" do
      context "with position lower than 0" do
        let(:position) { -1 }

        it { is_expected.not_to be_valid }
      end

      context "with position with decimals" do
        let(:position) { 1.75 }

        it { is_expected.not_to be_valid }
      end

      context "is set before creation" do
        context "when the step is the only one" do
          it "sets the position to 0" do
            subject.position = nil
            subject.save

            expect(subject.position).to eq 0
          end
        end

        context "when there are more steps in the same process" do
          let(:other_step) { create :participatory_process_step, :active, position: 3 }
          let(:participatory_process_step) do
            build(:participatory_process_step, participatory_process: other_step.participatory_process)
          end

          it "sets the position following the last step" do
            subject.position = nil
            subject.save

            expect(subject.position).to eq 4
          end
        end
      end
    end
  end
end
