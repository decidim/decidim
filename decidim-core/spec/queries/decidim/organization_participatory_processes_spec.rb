# frozen_string_literal: true

require "spec_helper"

describe Decidim::OrganizationParticipatoryProcesses do
  subject { described_class.new(organization) }

  let!(:organization) { create(:organization) }
  let!(:local_participatory_processes) do
    create_list(:participatory_process, 3, organization: organization)
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
  end
end
