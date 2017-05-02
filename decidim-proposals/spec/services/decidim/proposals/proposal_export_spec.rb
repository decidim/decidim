require "spec_helper"

module Decidim
  module Proposals
    describe ProposalExport do
      let(:feature) { create(:feature, manifest_name: "proposals") }
      let(:scope1) { create :scope, organization: feature.organization }
      let(:scope2) { create :scope, organization: feature.organization }
      let(:participatory_process) { feature.participatory_process }
      let(:user) { create(:user, organization: feature.organization) }
      let!(:proposal) { create_list(:proposal, 3, feature: feature, scope: scope1)}

      describe "export" do

        subject do
          described_class.new
        end

        it "returns the proposals in CSV format" do
          pending "pending"
          subject.export
        end
      end
    end
  end
end
