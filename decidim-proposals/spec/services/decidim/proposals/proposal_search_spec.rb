# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe ProposalSearch do
      subject { described_class.new(params).results }

      let(:component) { create(:component, manifest_name: "proposals") }
      let(:default_params) { { component: component, user: user } }
      let(:params) { default_params }
      let(:participatory_process) { component.participatory_space }
      let(:user) { create(:user, organization: component.organization) }

      it_behaves_like "a resource search", :proposal
      it_behaves_like "a resource search with scopes", :proposal
      it_behaves_like "a resource search with categories", :proposal
      it_behaves_like "a resource search with origin", :proposal

      describe "results" do
        let!(:proposal) { create(:proposal, component: component) }

        describe "search_text filter" do
          let(:params) { default_params.merge(search_text: search_text) }
          let(:search_text) { "dog" }

          it "returns the proposals containing the search in the title or the body" do
            create_list(:proposal, 3, component: component)
            create(:proposal, title: "A dog", component: component)
            create(:proposal, body: "There is a dog in the office", component: component)

            expect(subject.size).to eq(2)
          end
        end

        describe "activity filter" do
          let(:params) { default_params.merge(activity: activity) }

          context "when filtering by supported" do
            let(:activity) { "voted" }

            it "returns the proposals voted by the user" do
              create_list(:proposal, 3, component: component)
              create(:proposal_vote, proposal: Proposal.first, author: user)

              expect(subject.size).to eq(1)
            end
          end

          context "when filtering by my proposals" do
            let(:activity) { "my_proposals" }

            it "returns the proposals created by the user" do
              create_list(:proposal, 3, component: component)
              create(:proposal, component: component, users: [user])

              expect(subject.size).to eq(1)
            end
          end
        end

        describe "state filter" do
          let(:params) { default_params.merge(state: states) }

          context "when filtering for default states" do
            let(:states) { [] }

            it "returns all except withdrawn proposals" do
              create_list(:proposal, 3, :withdrawn, component: component)
              other_proposals = create_list(:proposal, 3, component: component)
              other_proposals << proposal

              expect(subject.size).to eq(4)
              expect(subject).to match_array(other_proposals)
            end
          end

          context "when filtering :except_rejected proposals" do
            let(:states) { %w(accepted evaluating state_not_published) }

            it "hides withdrawn and rejected proposals" do
              create(:proposal, :withdrawn, component: component)
              create(:proposal, :rejected, component: component)
              accepted_proposal = create(:proposal, :accepted, component: component)

              expect(subject.size).to eq(2)
              expect(subject).to match_array([accepted_proposal, proposal])
            end
          end

          context "when filtering accepted proposals" do
            let(:states) { %w(accepted) }

            it "returns only accepted proposals" do
              accepted_proposals = create_list(:proposal, 3, :accepted, component: component)
              create_list(:proposal, 3, component: component)

              expect(subject.size).to eq(3)
              expect(subject).to match_array(accepted_proposals)
            end
          end

          context "when filtering rejected proposals" do
            let(:states) { %w(rejected) }

            it "returns only rejected proposals" do
              create_list(:proposal, 3, component: component)
              rejected_proposals = create_list(:proposal, 3, :rejected, component: component)

              expect(subject.size).to eq(3)
              expect(subject).to match_array(rejected_proposals)
            end
          end

          context "when filtering withdrawn proposals" do
            let(:states) { %w(withdrawn) }

            it "returns only withdrawn proposals" do
              create_list(:proposal, 3, component: component)
              withdrawn_proposals = create_list(:proposal, 3, :withdrawn, component: component)

              expect(subject.size).to eq(3)
              expect(subject).to match_array(withdrawn_proposals)
            end
          end
        end

        describe "related_to filter" do
          let(:params) { default_params.merge(related_to: related_to) }

          context "when filtering by related to meetings" do
            let(:related_to) { "Decidim::Meetings::Meeting".underscore }
            let(:meetings_component) { create(:component, manifest_name: "meetings", participatory_space: participatory_process) }
            let(:meeting) { create :meeting, component: meetings_component }

            it "returns only proposals related to meetings" do
              related_proposal = create(:proposal, :accepted, component: component)
              related_proposal2 = create(:proposal, :accepted, component: component)
              create_list(:proposal, 3, component: component)
              meeting.link_resources([related_proposal], "proposals_from_meeting")
              related_proposal2.link_resources([meeting], "proposals_from_meeting")

              expect(subject).to match_array([related_proposal, related_proposal2])
            end
          end

          context "when filtering by related to resources" do
            let(:related_to) { "Decidim::DummyResources::DummyResource".underscore }
            let(:dummy_component) { create(:component, manifest_name: "dummy", participatory_space: participatory_process) }
            let(:dummy_resource) { create :dummy_resource, component: dummy_component }

            it "returns only proposals related to results" do
              related_proposal = create(:proposal, :accepted, component: component)
              related_proposal2 = create(:proposal, :accepted, component: component)
              create_list(:proposal, 3, component: component)
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
