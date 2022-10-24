# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatoryProcesses
  describe OrganizationPublishedParticipatoryProcesses do
    subject { described_class.new(organization) }

    let!(:organization) { create(:organization) }
    let!(:published_participatory_processes) do
      create(:participatory_process, :published, organization:, weight: 2)
      create(:participatory_process, :published, organization:, weight: 3)
      create(:participatory_process, :published, organization:, weight: 1)
    end

    let!(:unpublished_participatory_processes) do
      create_list(:participatory_process,
                  3,
                  :unpublished,
                  organization:)
    end

    let!(:foreign_participatory_processes) do
      create_list(:participatory_process, 3, :published)
    end

    describe "query" do
      it "includes the organization's published processes" do
        expect(subject).to include(*published_participatory_processes)
      end

      it "excludes the organization's unpublished processes" do
        expect(subject).not_to include(*unpublished_participatory_processes)
      end

      it "excludes other organization's published processes" do
        expect(subject).not_to include(*foreign_participatory_processes)
      end

      it "order published processes by weight" do
        expect(subject.to_a.first.weight).to eq 1
      end
    end
  end
end
