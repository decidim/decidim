# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe ProposalSearch do
      let(:feature) { create(:feature, manifest_name: "proposals") }
      let(:scope1) { create :scope, organization: feature.organization }
      let(:scope2) { create :scope, organization: feature.organization }
      let(:subscope1) { create :scope, organization: feature.organization, parent: scope1 }
      let(:participatory_process) { feature.participatory_space }
      let(:user) { create(:user, organization: feature.organization) }
      let!(:proposal) { create(:proposal, feature: feature, scope: scope1) }

      describe "results" do
        subject do
          described_class.new(
            feature: feature,
            activity: activity,
            search_text: search_text,
            state: state,
            origin: origin,
            related_to: related_to,
            scope_id: scope_id,
            current_user: user
          ).results
        end

        let(:activity) { [] }
        let(:search_text) { nil }
        let(:origin) { nil }
        let(:related_to) { nil }
        let(:state) { nil }
        let(:scope_id) { nil }

        it "only includes proposals from the given feature" do
          other_proposal = create(:proposal)

          expect(subject).to include(proposal)
          expect(subject).not_to include(other_proposal)
        end

        describe "search_text filter" do
          let(:search_text) { "dog" }

          it "returns the proposals containing the search in the title or the body" do
            create_list(:proposal, 3, feature: feature)
            create(:proposal, title: "A dog", feature: feature)
            create(:proposal, body: "There is a dog in the office", feature: feature)

            expect(subject.size).to eq(2)
          end
        end

        describe "activity filter" do
          let(:activity) { ["voted"] }

          it "returns the proposals voted by the user" do
            create_list(:proposal, 3, feature: feature)
            create(:proposal_vote, proposal: Proposal.first, author: user)

            expect(subject.size).to eq(1)
          end
        end

        describe "origin filter" do
          context "when filtering official proposals" do
            let(:origin) { "official" }

            it "returns only official proposals" do
              official_proposals = create_list(:proposal, 3, :official, feature: feature)
              create_list(:proposal, 3, feature: feature)

              expect(subject.size).to eq(3)
              expect(subject).to match_array(official_proposals)
            end
          end

          context "when filtering citizen proposals" do
            let(:origin) { "citizens" }

            it "returns only citizen proposals" do
              create_list(:proposal, 3, :official, feature: feature)
              citizen_proposals = create_list(:proposal, 2, feature: feature)
              citizen_proposals << proposal

              expect(subject.size).to eq(3)
              expect(subject).to match_array(citizen_proposals)
            end
          end
        end

        describe "state filter" do
          context "when filtering accpeted proposals" do
            let(:state) { "accepted" }

            it "returns only accepted proposals" do
              accepted_proposals = create_list(:proposal, 3, :accepted, feature: feature)
              create_list(:proposal, 3, feature: feature)

              expect(subject.size).to eq(3)
              expect(subject).to match_array(accepted_proposals)
            end
          end

          context "when filtering rejected proposals" do
            let(:state) { "rejected" }

            it "returns only rejected proposals" do
              create_list(:proposal, 3, feature: feature)
              rejected_proposals = create_list(:proposal, 3, :rejected, feature: feature)

              expect(subject.size).to eq(3)
              expect(subject).to match_array(rejected_proposals)
            end
          end
        end

        describe "scope_id filter" do
          let!(:proposal2) { create(:proposal, feature: feature, scope: scope2) }
          let!(:proposal3) { create(:proposal, feature: feature, scope: subscope1) }

          context "when a parent scope id is being sent" do
            let(:scope_id) { scope1.id }

            it "filters proposals by scope" do
              expect(subject).to match_array [proposal, proposal3]
            end
          end

          context "when a subscope id is being sent" do
            let(:scope_id) { subscope1.id }

            it "filters proposals by scope" do
              expect(subject).to eq [proposal3]
            end
          end

          context "when multiple ids are sent" do
            let(:scope_id) { [scope2.id, scope1.id] }

            it "filters proposals by scope" do
              expect(subject).to match_array [proposal, proposal2, proposal3]
            end
          end

          context "when `global` is being sent" do
            let!(:resource_without_scope) { create(:proposal, feature: feature, scope: nil) }
            let(:scope_id) { ["global"] }

            it "returns proposals without a scope" do
              expect(subject).to eq [resource_without_scope]
            end
          end

          context "when `global` and some ids is being sent" do
            let!(:resource_without_scope) { create(:proposal, feature: feature, scope: nil) }
            let(:scope_id) { ["global", scope2.id, scope1.id] }

            it "returns proposals without a scope and with selected scopes" do
              expect(subject).to match_array [resource_without_scope, proposal, proposal2, proposal3]
            end
          end
        end

        describe "related_to filter" do
          context "when filtering by related to meetings" do
            let(:related_to) { "Decidim::Meetings::Meeting".underscore }
            let(:meetings_feature) { create(:feature, manifest_name: "meetings", participatory_space: participatory_process) }
            let(:meeting) { create :meeting, feature: meetings_feature }

            it "returns only proposals related to meetings" do
              related_proposal = create(:proposal, :accepted, feature: feature)
              related_proposal2 = create(:proposal, :accepted, feature: feature)
              create_list(:proposal, 3, feature: feature)
              meeting.link_resources([related_proposal], "proposals_from_meeting")
              related_proposal2.link_resources([meeting], "proposals_from_meeting")

              expect(subject).to match_array([related_proposal, related_proposal2])
            end
          end

          context "when filtering by related to resources" do
            let(:related_to) { "Decidim::DummyResources::DummyResource".underscore }
            let(:dummy_feature) { create(:feature, manifest_name: "dummy", participatory_space: participatory_process) }
            let(:dummy_resource) { create :dummy_resource, feature: dummy_feature }

            it "returns only proposals related to results" do
              related_proposal = create(:proposal, :accepted, feature: feature)
              related_proposal2 = create(:proposal, :accepted, feature: feature)
              create_list(:proposal, 3, feature: feature)
              dummy_resource.link_resources([related_proposal], "included_proposals")
              related_proposal2.link_resources([dummy_resource], "included_proposals")

              expect(subject).to match_array([related_proposal, related_proposal2])
            end
          end
        end
      end
    end
  end
end
