# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatoryProcesses
  describe OrganizationParticipatoryProcesses do
    subject { described_class.new(organization) }

    let!(:organization) { create(:organization) }
    let!(:local_participatory_processes) do
      create(:participatory_process, organization:, weight: 2)
      create(:participatory_process, organization:, weight: 3)
      create(:participatory_process, organization:, weight: 1)
    end

    let!(:foreign_participatory_processes) do
      create_list(:participatory_process, 3)
    end

    describe "query" do
      it "includes the organization's processes" do
        expect(subject).to include(*local_participatory_processes)
      end

      it "excludes the external processes" do
        expect(subject).not_to include(*foreign_participatory_processes)
      end

      it "order processes by weight" do
        expect(subject.to_a.first.weight).to eq 1
      end
    end
  end
end
