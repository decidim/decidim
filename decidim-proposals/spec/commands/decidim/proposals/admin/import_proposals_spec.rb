# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe ImportProposals do
        describe "call" do
          let!(:organization) { create(:organization) }
          let!(:proposal) { create(:proposal, :accepted, component: proposal_component) }
          let!(:proposal_component) do
            create(
              :proposal_component,
              organization:
            )
          end
          let!(:current_component) do
            create(
              :proposal_component,
              participatory_space: proposal_component.participatory_space,
              organization:
            )
          end

          let(:form) do
            instance_double(
              ProposalsImportForm,
              origin_component: proposal_component,
              current_component:,
              current_organization: organization,
              keep_authors:,
              keep_answers:,
              states:,
              scopes:,
              scope_ids:,
              current_user: create(:user, organization:),
              valid?: valid
            )
          end
          let(:keep_authors) { false }
          let(:keep_answers) { false }
          let(:states) { ["accepted"] }
          let(:scopes) { [] }
          let(:scope_ids) { scopes.map(&:id) }
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
              let(:second_proposal) { create(:proposal, :accepted, component: proposal_component) }

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
              expect(new_proposal.creator_author).to eq(organization)
              expect(new_proposal.category).to eq(proposal.category)

              expect(new_proposal.state).to be_nil
              expect(new_proposal.answer).to be_nil
              expect(new_proposal.answered_at).to be_nil
              expect(new_proposal.reference).not_to eq(proposal.reference)
              expect(new_proposal.comments_count).to eq 0
              expect(new_proposal.endorsements_count).to eq 0
              expect(new_proposal.follows_count).to eq 0
              expect(new_proposal.proposal_notes_count).to eq 0
              expect(new_proposal.proposal_votes_count).to eq 0
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

            describe "when keep_answers is true" do
              let(:keep_answers) { true }

              it "keeps the proposal state and answers" do
                command.call

                new_proposal = Proposal.where(component: current_component).last
                expect(new_proposal.answer).to eq(proposal.answer)
                expect(new_proposal.answered_at).to be_within(1.second).of(proposal.answered_at)
                expect(new_proposal.state).to eq(proposal.state)
                expect(new_proposal.state_published_at).to be_within(1.second).of(proposal.state_published_at)
              end
            end

            describe "proposal states" do
              let(:states) { %w(not_answered rejected) }

              before do
                create(:proposal, :rejected, component: proposal_component)
                create(:proposal, component: proposal_component)
              end

              it "only imports proposals from the selected states" do
                expect do
                  command.call
                end.to change { Proposal.where(component: current_component).count }.by(2)

                expect(Proposal.where(component: current_component).pluck(:title)).not_to include(proposal.title)
              end
            end

            describe "proposal scopes" do
              let(:states) { ProposalsImportForm::VALID_STATES.dup }
              let(:scope) { create(:scope, organization:) }
              let(:other_scope) { create(:scope, organization:) }

              let(:scopes) { [scope] }
              let(:scope_ids) { [scope.id] }

              let!(:proposals) do
                [
                  create(:proposal, component: proposal_component, scope:),
                  create(:proposal, component: proposal_component, scope: other_scope)
                ]
              end

              it "only imports proposals from the selected scope" do
                expect do
                  command.call
                end.to change { Proposal.where(component: current_component).count }.by(1)

                expect(Proposal.where(component: current_component).pluck(:decidim_scope_id)).to eq([scope.id])
              end

              context "when the global scope is selected" do
                let(:scope) { nil }
                let(:scope_ids) { [nil] }

                it "only imports proposals from the global scope" do
                  expect do
                    command.call
                  end.to change { Proposal.where(component: current_component).count }.by(2)

                  expect(Proposal.where(component: current_component).pluck(:decidim_scope_id)).to eq([nil, nil])
                end
              end
            end

            describe "when the proposal has attachments" do
              let!(:attachment) do
                create(:attachment, attached_to: proposal)
              end

              it "duplicates the attachments" do
                expect do
                  command.call
                end.to change(Attachment, :count).by(1)

                new_proposal = Proposal.where(component: current_component).last
                expect(new_proposal.attachments.count).to eq(1)
              end
            end
          end
        end
      end
    end
  end
end
