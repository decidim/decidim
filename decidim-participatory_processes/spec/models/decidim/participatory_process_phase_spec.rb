# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryProcesses
    describe ParticipatoryProcessPhase do
      subject { participatory_process_phase }

      let(:participatory_process_phase) { build(:participatory_process_phase, position:) }
      let(:position) { nil }

      it { is_expected.to be_valid }
      it { is_expected.to be_versioned }

      context "when start date is after end date" do
        let(:participatory_process_phase) do
          build(:participatory_process_phase, start_date: 2.months.from_now, end_date: 1.month.ago)
        end

        it { is_expected.not_to be_valid }

        it "has an error in end_date" do
          subject.valid?

          expect(subject.errors[:end_date]).not_to be_empty
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

      context "when active" do
        context "when there is an active phase in the same process" do
          let(:active_phase) { create(:participatory_process_phase, :active) }
          let(:participatory_process_phase) do
            build(:participatory_process_phase, :active, participatory_process: active_phase.participatory_process)
          end

          it { is_expected.not_to be_valid }
        end

        context "with multiple inactive phases" do
          let(:inactive_phase) { create(:participatory_process_phase) }
          let(:participatory_process_phase) do
            build(:participatory_process_phase, participatory_process: inactive_phase.participatory_process)
          end

          it { is_expected.to be_valid }
        end
      end

      context "with position lower than 0" do
        let(:position) { -1 }

        it { is_expected.not_to be_valid }
      end

      context "with position with decimals" do
        let(:position) { 1.75 }

        it { is_expected.not_to be_valid }
      end

      context "when set before creation" do
        context "when the phase is the only one" do
          it "sets the position to 0" do
            subject.position = nil
            subject.save

            expect(subject.position).to eq 0
          end
        end

        context "when there are more phases in the same process" do
          let(:other_phase) { create(:participatory_process_phase, :active, position: 3) }
          let(:participatory_process_phase) do
            build(:participatory_process_phase, participatory_process: other_phase.participatory_process, position:)
          end

          context "and position is automatically set" do
            let(:position) { nil }

            it "sets the position following the last phase" do
              subject.save

              expect(subject.position).to eq 4
            end
          end

          context "and position is manually set" do
            let(:position) { 3 }

            it "does not let two phases to have the same position" do
              expect(subject).not_to be_valid
            end
          end
        end
      end

      context "when multiple processes have only one phase" do
        let!(:other_phase) { create(:participatory_process_phase) }

        it "all phases have position 0" do
          subject.save
          expect(subject.position).to eq 0
          expect(other_phase.position).to eq 0
        end
      end

      context "when parent process is touched on phase update" do
        let(:participatory_process) { create(:participatory_process) }
        let(:participatory_process_phase) do
          create(:participatory_process_phase, participatory_process:)
        end

        it "touches the parent process" do
          original_updated_at = participatory_process.updated_at

          travel_to(1.second.from_now) do
            participatory_process_phase.save
          end

          expect(participatory_process.reload.updated_at).to be > original_updated_at
        end

        it "changes the process cache_key when phase is updated" do
          original_cache_key = participatory_process.cache_key_with_version

          travel_to(1.second.from_now) do
            participatory_process_phase.save
          end

          expect(participatory_process.reload.cache_key_with_version).not_to eq(original_cache_key)
        end
      end
    end
  end
end
