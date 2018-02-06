# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe ImportProposals do
        describe "call" do
          let!(:proposal) { create(:proposal, :accepted) }
          let(:current_feature) do
            create(
              :proposal_feature,
              participatory_space: proposal.feature.participatory_space
            )
          end
          let(:form) do
            instance_double(
              ProposalsImportForm,
              origin_feature: proposal.feature,
              current_feature: current_feature,
              states: states,
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
              end.to change { Proposal.count }.by(0)
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
              end.to change { Proposal.where(feature: current_feature).count }.by(1)
            end

            it "links the proposals" do
              command.call

              linked = proposal.linked_resources(:proposals, "copied_from_component")
              new_proposal = Proposal.where(feature: current_feature).last

              expect(linked).to include(new_proposal)
            end

            it "only imports wanted attributes" do
              command.call

              new_proposal = Proposal.where(feature: current_feature).last

              expect(new_proposal.title).to eq(proposal.title)
              expect(new_proposal.body).to eq(proposal.body)
              expect(new_proposal.author).to eq(proposal.author)
              expect(new_proposal.category).to eq(proposal.category)

              expect(new_proposal.state).to be_nil
              expect(new_proposal.answer).to be_nil
              expect(new_proposal.answered_at).to be_nil
              expect(new_proposal.reference).not_to eq(proposal.reference)
            end

            describe "proposal states" do
              let(:states) { %w(not_answered rejected) }

              before do
                create(:proposal, :rejected, feature: proposal.feature)
                create(:proposal, feature: proposal.feature)
              end

              it "only imports proposals from the selected states" do
                expect do
                  command.call
                end.to change { Proposal.where(feature: current_feature).count }.by(2)

                expect(Proposal.where(feature: current_feature).pluck(:title)).not_to include(proposal.title)
              end
            end
          end
        end
      end
    end
  end
end
