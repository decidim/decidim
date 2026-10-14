# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ParticipatoryProcesses::ParticipatoryProcessesStatsFollowersCount do
    subject { described_class.for(participatory_space) }

    let(:organization) { create(:organization) }
    let(:participatory_space) { create(:participatory_process, organization:) }

    it "counts followers of the participatory process itself" do
      create(:follow, user: create(:user, :confirmed, organization:), followable: participatory_space)

      expect(subject).to eq(1)
    end

    context "when counting a participatory process group" do
      let(:participatory_space) { create(:participatory_process_group, organization:) }
      let!(:first_process) { create(:participatory_process, organization:, participatory_process_group: participatory_space) }
      let!(:second_process) { create(:participatory_process, organization:, participatory_process_group: participatory_space) }

      it "counts followers of every process in the group" do
        create(:follow, user: create(:user, :confirmed, organization:), followable: first_process)
        create(:follow, user: create(:user, :confirmed, organization:), followable: second_process)

        expect(subject).to eq(2)
      end
    end
  end
end
