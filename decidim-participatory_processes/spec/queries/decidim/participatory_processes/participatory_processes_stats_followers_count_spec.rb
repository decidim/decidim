# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ParticipatoryProcesses::ParticipatoryProcessesStatsFollowersCount do
    subject { described_class.for(participatory_space) }

    let(:organization) { create(:organization) }
    let(:participatory_space) { create(:participatory_process, organization:) }

    it "counts followers of the participatory process and its components" do
      create(:follow, user: create(:user, :confirmed, organization:), followable: participatory_space)
      proposal = create(:proposal, component: create(:proposal_component, :published, participatory_space:))
      create(:follow, user: create(:user, :confirmed, organization:), followable: proposal)

      expect(subject).to eq(2)
    end

    context "when counting a participatory process group" do
      let(:participatory_space) { create(:participatory_process_group, organization:) }
      let!(:first_process) { create(:participatory_process, organization:, participatory_process_group: participatory_space) }
      let!(:second_process) { create(:participatory_process, organization:, participatory_process_group: participatory_space) }

      it "counts followers of every process and their components in the group" do
        create(:follow, user: create(:user, :confirmed, organization:), followable: first_process)
        create(:follow, user: create(:user, :confirmed, organization:), followable: second_process)
        proposal = create(:proposal, component: create(:proposal_component, :published, participatory_space: first_process))
        create(:follow, user: create(:user, :confirmed, organization:), followable: proposal)

        expect(subject).to eq(3)
      end
    end
  end
end
