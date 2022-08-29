# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatoryProcesses
  describe OrganizationPrioritizedParticipatoryProcesses do
    subject { described_class.new(organization) }

    let!(:organization) { create(:organization) }
    let!(:local_promoted_process_ending_first) do
      create(:participatory_process,
             :promoted,
             :with_steps,
             organization:,
             current_step_ends: 1.month.from_now)
    end

    let!(:local_promoted_process_ending_last) do
      create(:participatory_process,
             :promoted,
             :with_steps,
             organization:,
             current_step_ends: 2.months.from_now)
    end

    let!(:local_non_promoted_process_with_steps) do
      create(:participatory_process,
             :published,
             :with_steps,
             organization:)
    end

    let!(:local_non_promoted_process_without_steps) do
      create(:participatory_process, :published, organization:)
    end

    before { create(:participatory_process) }

    describe "query" do
      it "orders by promoted status first, and then by closest end date" do
        expect(subject.to_a).to eq [
          local_promoted_process_ending_first,
          local_promoted_process_ending_last,
          local_non_promoted_process_with_steps,
          local_non_promoted_process_without_steps
        ]
      end
    end
  end
end
