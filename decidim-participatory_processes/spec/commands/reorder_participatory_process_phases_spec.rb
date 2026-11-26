# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatoryProcesses
  describe Admin::ReorderParticipatoryProcessPhases do
    subject { described_class.new(collection, order) }

    let(:process) { create(:participatory_process) }
    let!(:process_phase1) do
      create(
        :participatory_process_phase,
        participatory_process: process,
        position: 1
      )
    end
    let!(:process_phase2) do
      create(
        :participatory_process_phase,
        participatory_process: process,
        position: 2
      )
    end
    let(:collection) { process.phases }
    let(:order) { [process_phase2.id, process_phase1.id] }

    context "when the order is nil" do
      let(:order) { nil }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the order is empty" do
      let(:order) { [] }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the order is valid" do
      it "is valid" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "reorders the phases" do
        subject.call
        process_phase1.reload
        process_phase2.reload
        expect(process_phase1.position).to eq 1
        expect(process_phase2.position).to eq 0
      end
    end
  end
end
