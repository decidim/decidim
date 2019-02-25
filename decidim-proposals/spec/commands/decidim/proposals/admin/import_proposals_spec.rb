# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe ImportProposals do
        describe "call" do
          let!(:proposal) { create(:proposal, :accepted) }
          let(:keep_authors) { false }
          let(:current_component) do
            create(
              :proposal_component,
              participatory_space: proposal.component.participatory_space
            )
          end
          let(:form) do
            instance_double(
              ProposalsImportForm,
              origin_component: proposal.component,
              current_component: current_component,
              current_organization: current_component.organization,
              keep_authors: keep_authors,
              states: states,
              current_user: create(:user),
              valid?: valid
            )
          end
          let(:states) { ["accepted"] }
          let(:command) { described_class.new(form) }

          describe "when the form is not valid" do
            let(:valid) { false }

            it "broadcasts invalid" do
              expect { command.call }.to broadcast(:invalid)
            end

            it "doesn't create the proposal" do
              expect do
                command.call
              end.to change(Proposal, :count).by(0)
            end
          end

          describe "when the form is valid" do
            let(:valid) { true }

            it "broadcasts ok" do
              expect { command.call }.to broadcast(:ok)
            end

            it "creates the proposals" do
              expect do
                command.call
              end.to change { Proposal.where(component: current_component).count }.by(1)
            end

            context "when a proposal was already imported" do
              let(:second_proposal) { create(:proposal, :accepted, component: proposal.component) }

              before do
                command.call
                second_proposal
              end

              it "doesn't import it again" do
                expect do
                  command.call
                end.to change { Proposal.where(component: current_component).count }.by(1)

                titles = Proposal.where(component: current_component).map(&:title)
                expect(titles).to match_array([proposal.title, second_proposal.title])
              end
            end

            it "links the proposals" do
              command.call

              linked = proposal.linked_resources(:proposals, "copied_from_component")
              new_proposal = Proposal.where(component: current_component).last

              expect(linked).to include(new_proposal)
            end

            it "only imports wanted attributes" do
              command.call

              new_proposal = Proposal.where(component: current_component).last
              expect(new_proposal.title).to eq(proposal.title)
              expect(new_proposal.body).to eq(proposal.body)
              expect(new_proposal.creator_author).to eq(current_component.organization)
              expect(new_proposal.category).to eq(proposal.category)

              expect(new_proposal.state).to be_nil
              expect(new_proposal.answer).to be_nil
              expect(new_proposal.answered_at).to be_nil
              expect(new_proposal.reference).not_to eq(proposal.reference)
            end

            describe "when keep_authors is true" do
              let(:keep_authors) { true }

              it "only keeps the proposal authors" do
                command.call

                new_proposal = Proposal.where(component: current_component).last
                expect(new_proposal.title).to eq(proposal.title)
                expect(new_proposal.body).to eq(proposal.body)
                expect(new_proposal.creator_author).to eq(proposal.creator_author)
              end
            end

            describe "proposal states" do
              let(:states) { %w(not_answered rejected) }

              before do
                create(:proposal, :rejected, component: proposal.component)
                create(:proposal, component: proposal.component)
              end

              it "only imports proposals from the selected states" do
                expect do
                  command.call
                end.to change { Proposal.where(component: current_component).count }.by(2)

                expect(Proposal.where(component: current_component).pluck(:title)).not_to include(proposal.title)
              end
            end
          end
        end
      end
    end
  end
end
