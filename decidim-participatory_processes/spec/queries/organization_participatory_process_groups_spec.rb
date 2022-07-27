# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatoryProcesses
  describe OrganizationParticipatoryProcessGroups do
    subject { described_class.new(organization) }

    let!(:organization) { create(:organization) }

    let!(:local_participatory_process_groups) do
      create_list(:participatory_process_group, 3, organization:)
    end

    let!(:foreign_participatory_process_groups) do
      create_list(:participatory_process_group, 3)
    end

    describe "query" do
      it "includes the organization's processes" do
        expect(subject).to include(*local_participatory_process_groups)
      end

      it "excludes the external processes" do
        expect(subject).not_to include(*foreign_participatory_process_groups)
      end
    end
  end
end
