# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe ApplicationHelper do
      let(:helper) do
        Class.new.tap do |v|
          v.extend(Decidim::Proposals::ApplicationHelper)
        end
      end

      describe "humanize_proposal_state" do
        subject { helper.humanize_proposal_state(state) }

        context "when it is accepted" do
          let(:state) { "accepted" }

          it { is_expected.to eq("Accepted") }
        end

        context "when it is rejected" do
          let(:state) { "rejected" }

          it { is_expected.to eq("Rejected") }
        end

        context "when it is nil" do
          let(:state) { nil }

          it { is_expected.to eq("Not answered") }
        end

        context "when it is withdrawn" do
          let(:state) { "withdrawn" }

          it { is_expected.to eq("Withdrawn") }
        end
      end

      describe "Selection of authorship identity" do
        subject { helper }

        let!(:organization) { create(:organization) }
        let!(:component) { create(:component, organization: organization, manifest_name: "proposals") }
        let!(:participatory_process) { create(:participatory_process, organization: organization) }
        let!(:author) { create(:user, organization: organization) }
        let!(:user_group) { create(:user_group, verified_at: DateTime.current) }
        let!(:proposal) { create(:proposal, component: component, author: author) }

        context "when the model belongs to a user" do
          let!(:endorsement) do
            build(:proposal_endorsement, proposal: proposal, author: author)
          end

          it "returns the user author of the endorsement" do
            expect(subject.select_authorship_identity(endorsement)).to eq author
          end
        end
        context "when the endorsement belongs to a user_group" do
          let!(:endorsement) do
            build(:proposal_endorsement, proposal: proposal, author: author,
                                         user_group: user_group)
          end

          it "returns the user_group that endorsed" do
            expect(helper.select_authorship_identity(endorsement)).to eq user_group
          end
        end
      end
    end
  end
end
