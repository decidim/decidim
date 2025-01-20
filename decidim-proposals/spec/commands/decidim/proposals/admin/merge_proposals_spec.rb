# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe MergeProposals do
        describe "call" do
          let!(:proposals) { create_list(:proposal, 3, component: current_component) }
          let!(:current_component) { create(:proposal_component) }
          let!(:target_component) { create(:proposal_component, participatory_space: current_component.participatory_space) }
          let!(:author) { create(:organization) }
          let(:form) do
            instance_double(
              ProposalsMergeForm,
              current_component:,
              current_organization: current_component.organization,
              target_component:,
              proposals:,
              valid?: valid,
              same_component?: same_component,
              current_user: create(:user, :admin, organization: current_component.organization),
              add_photos: [],
              add_documents: [],
              title: { "en" => "Valid Long Proposal Title" },
              body: { "en" => "Valid body text" },
              address: "",
              latitude: "",
              longitude: "",
              created_in_meeting: false,
              created_in_meeting?: false,
              author:
            )
          end
          let(:command) { described_class.new(form) }
          let(:same_component) { false }

          describe "when the form is not valid" do
            let(:valid) { false }

            it "broadcasts invalid" do
              expect { command.call }.to broadcast(:invalid)
            end

            it "does not create the proposal" do
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

            it "creates a proposal in the new component" do
              expect do
                command.call
              end.to change { Proposal.where(component: target_component).count }.by(1)
            end

            it "links the proposals" do
              command.call
              proposal = Proposal.where(component: target_component).last

              linked = proposal.linked_resources(:proposals, "merged_from_component")

              expect(linked).to match_array(proposals)
            end

            it "only merges wanted attributes" do
              command.call
              new_proposal = Proposal.where(component: target_component).last
              proposal = proposals.first

              expect(new_proposal.title).to eq({ "en" => "Valid Long Proposal Title" })
              expect(new_proposal.body).to eq({ "en" => "Valid body text" })
              expect(new_proposal.creator_author).to eq(current_component.organization)
              expect(new_proposal.category).to eq(proposal.category)

              expect(new_proposal.state).to be_nil
              expect(new_proposal.answer).to be_nil
              expect(new_proposal.answered_at).to be_nil
              expect(new_proposal.reference).not_to eq(proposal.reference)
            end
          end
        end
      end
    end
  end
end
