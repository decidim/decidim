# frozen_string_literal: true
require "spec_helper"

describe Decidim::OrganizationProcesses do
  let!(:external_process) { create :participatory_process }
  let!(:organization_process) { create :participatory_process }
  let(:organization) { organization_process.organization }

  subject { described_class.new(organization) }

  describe "#query" do
    context "when no organization is given" do
      let(:organization) { }

      it "returns an empty relation" do
        expect(subject.query).to eq []
        expect(subject.query).to be_kind_of(ActiveRecord::Relation)
      end
    end

    it "only returns the processes form the given organization" do
      expect(subject.query).to eq [organization_process]
    end
  end
end
