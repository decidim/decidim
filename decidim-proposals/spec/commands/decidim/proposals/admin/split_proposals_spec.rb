# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe SplitProposals do
        describe "call" do
          let!(:proposals) { Array(create(:proposal, component: current_component)) }
          let!(:current_component) { create(:proposal_component) }
          let!(:target_component) { create(:proposal_component, participatory_space: current_component.participatory_space) }
          let(:form) do
            instance_double(
              ProposalsSplitForm,
              current_component: current_component,
              current_organization: current_component.organization,
              target_component: target_component,
              proposals: proposals,
              valid?: valid,
              same_component?: same_component,
              current_user: create(:user, :admin, organization: current_component.organization)
            )
          end
          let(:command) { described_class.new(form) }
          let(:same_component) { false }

          describe "when the form is not valid" do
            let(:valid) { false }

            it "broadcasts invalid" do
              expect { command.call }.to broadcast(:invalid)
            end

            it "doesn't create the proposal" do
              expect do
                command.call
              end.not_to change(Proposal, :count)
            end
          end

          describe "when the form is valid" do
            let(:valid) { true }

            it "broadcasts ok" do
              expect { command.call }.to broadcast(:ok)
            end

            it "creates two proposals for each original in the new component" do
              expect do
                command.call
              end.to change { Proposal.where(component: target_component).count }.by(2)
            end

            it "links the proposals" do
              command.call
              new_proposals = Proposal.where(component: target_component)

              linked = proposals.first.linked_resources(:proposals, "copied_from_component")

              expect(linked).to match_array(new_proposals)
            end

            it "only copies wanted attributes" do
              command.call
              proposal = proposals.first
              new_proposal = Proposal.where(component: target_component).last

              expect(new_proposal.title).to eq(proposal.title)
              expect(new_proposal.body).to eq(proposal.body)
              expect(new_proposal.creator_author).to eq(current_component.organization)
              expect(new_proposal.category).to eq(proposal.category)

              expect(new_proposal.state).to be_nil
              expect(new_proposal.answer).to be_nil
              expect(new_proposal.answered_at).to be_nil
              expect(new_proposal.reference).not_to eq(proposal.reference)
            end

            context "when spliting to the same component" do
              let(:same_component) { true }
              let!(:target_component) { current_component }
              let!(:proposals) { create_list(:proposal, 2, component: current_component) }

              it "only creates one copy for each proposal" do
                expect do
                  command.call
                end.to change { Proposal.where(component: current_component).count }.by(2)
              end

              context "when the original proposal has links to other proposals" do
                let(:previous_component) { create(:proposal_component, participatory_space: current_component.participatory_space) }
                let(:previous_proposals) { create(:proposal, component: previous_component) }

                before do
                  proposals.each do |proposal|
                    proposal.link_resources(previous_proposals, "copied_from_component")
                  end
                end

                it "links the copy to the same links the proposal has" do
                  new_proposals = Proposal.where(component: target_component).last(2)

                  new_proposals.each do |proposal|
                    linked = proposal.linked_resources(:proposals, "copied_from_component")
                    expect(linked).to eq([previous_proposals])
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
