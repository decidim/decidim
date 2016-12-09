# frozen_string_literal: true
require "spec_helper"

module Decidim
  describe OrganizationParticipatoryProcesses do
    subject { described_class.new(organization) }

    let!(:organization) { create(:organization) }
    let!(:published_participatory_processes) do
      create_list(:participatory_process,
                  3,
                  :published,
                  organization: organization)
    end

    let!(:unpublished_participatory_processes) do
      create_list(:participatory_process,
                  3,
                  :unpublished,
                  organization: organization)
    end

    let!(:foreign_participatory_processes) do
      create_list(:participatory_process,
                  3,
                  :published)
    end

    describe "query" do
      context "with an organization" do
        it "includes the organization's published processes" do
          expect(subject).to include(*published_participatory_processes)
        end

        it "excludes the organization's unpublished processes" do
          expect(subject).to_not include(*unpublished_participatory_processes)
        end

        it "excludes other organization's published processes" do
          expect(subject).to_not include(*foreign_participatory_processes)
        end
      end

      context "without an organization" do
        let(:organization) { nil }

        it "raises an exception" do
          expect do
            subject.to_a
          end.to raise_error(OrganizationParticipatoryProcesses::MandatoryOrganization)
        end
      end
    end
  end
end
