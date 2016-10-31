# frozen_string_literal: true
require "spec_helper"

describe Decidim::OrganizationProcesses do
  let!(:external_process) { create :participatory_process }
  let!(:organization_process) { create :participatory_process }

  subject { described_class.new(organization_process.organization) }

  describe "#query" do
    it "only returns the processes form the given organization" do
      expect(subject.query).to eq [organization_process]
    end
  end
end
