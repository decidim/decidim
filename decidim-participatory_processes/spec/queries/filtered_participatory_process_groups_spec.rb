# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatoryProcesses
  describe FilteredParticipatoryProcessGroups do
    subject { query }

    let(:query) { described_class.new(filter) }

    let(:organization) { create(:organization) }

    # Active
    let(:active_group) { create(:participatory_process_group, organization:) }
    let!(:active_participatory_process) { create(:participatory_process, start_date: Date.current, end_date: 2.months.from_now, participatory_process_group: active_group, organization:) }

    # Past
    let(:past_group) { create(:participatory_process_group, organization:) }
    let!(:past_participatory_process) { create(:participatory_process, start_date: 2.months.ago, end_date: 1.day.ago, participatory_process_group: past_group, organization:) }

    # Upcoming
    let(:upcoming_group) { create(:participatory_process_group, organization:) }
    let!(:upcoming_participatory_process) { create(:participatory_process, start_date: 1.day.from_now, end_date: 2.months.from_now, participatory_process_group: upcoming_group, organization:) }

    describe "#query" do
      subject { query.query }

      context "with active filter" do
        let(:filter) { "active" }

        it "returns only the active group" do
          expect(subject.count).to eq(1)
          expect(subject.first).to eq(active_group)
        end

        context "when the end date is the current date" do
          let!(:active_participatory_process) { create(:participatory_process, start_date: 2.months.ago, end_date: Date.current, participatory_process_group: active_group, organization:) }

          it "returns only the active group" do
            expect(subject.count).to eq(1)
            expect(subject.first).to eq(active_group)
          end
        end

        context "when end date is not set" do
          let!(:active_participatory_process) { create(:participatory_process, start_date: 2.months.ago, end_date: nil, participatory_process_group: active_group, organization:) }

          it "returns only the active group" do
            expect(subject.count).to eq(1)
            expect(subject.first).to eq(active_group)
          end
        end
      end

      context "with past filter" do
        let(:filter) { "past" }

        it "returns only the past group" do
          expect(subject.count).to eq(1)
          expect(subject.first).to eq(past_group)
        end
      end

      context "with upcoming filter" do
        let(:filter) { "upcoming" }

        it "returns only the upcoming group" do
          expect(subject.count).to eq(1)
          expect(subject.first).to eq(upcoming_group)
        end
      end

      context "with all filter" do
        let(:filter) { "all" }

        it "returns all groups" do
          expect(subject.count).to eq(3)
          expect(subject).to include(active_group)
          expect(subject).to include(past_group)
          expect(subject).to include(upcoming_group)
        end
      end
    end
  end
end
