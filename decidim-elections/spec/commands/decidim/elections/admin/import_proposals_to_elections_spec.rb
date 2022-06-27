# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Elections
    module Admin
      describe ImportProposalsToElections do
        describe "call" do
          let!(:proposals) { create_list(:proposal, 3, :accepted) }
          let!(:proposal) { proposals.first }
          let!(:organization) { component.participatory_space.organization }
          let!(:user) { create :user, :admin, :confirmed, organization: organization }
          let(:component) do
            create(
              :component, manifest_name: "elections",
                          participatory_space: proposal.component.participatory_space
            )
          end
          let(:question) { create :question, election: election }
          let(:election) { create :election, component: component }
          let!(:form) do
            instance_double(
              AnswerImportProposalsForm,
              origin_component: proposal.component,
              current_component: component,
              current_user: user,
              import_all_accepted_proposals?: import_all_accepted_proposals,
              invalid?: invalid,
              election: election,
              question: question,
              weight: 10
            )
          end

          let(:import_all_accepted_proposals) { true }
          let(:invalid) { false }
          let(:command) { described_class.new(form) }

          describe "when the form is not valid" do
            let(:invalid) { true }

            it "broadcasts invalid" do
              expect { command.call }.to broadcast(:invalid)
            end

            it "doesn't create the answer" do
              expect do
                command.call
              end.not_to change(Decidim::Elections::Answer, :count)
            end
          end

          describe "when the form is valid" do
            it "broadcasts ok" do
              expect { command.call }.to broadcast(:ok)
            end

            it "creates the answer" do
              expect do
                command.call
              end.to change { Decidim::Elections::Answer.where(question: question).count }.by(1)
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
                end.not_to(change { Decidim::Elections::Answer.where(question: question).count })

                answers = Decidim::Elections::Answer.where(question: question)
                first_answer = answers.first
                last_answer = answers.last
                expect(first_answer.title).to eq(proposal.title)
                expect(last_answer.title).to eq(proposal.title)
              end
            end

            it "links the proposals" do
              command.call
              last_answer = Decidim::Elections::Answer.where(question: question).last

              linked = last_answer.linked_resources(:proposals, "related_proposals")

              expect(linked).to include(proposal)
            end

            it "imports wanted attributes" do
              command.call

              new_answer = Decidim::Elections::Answer.where(question: question).last
              expect(new_answer.title).to eq(proposal.title)
              expect(new_answer.description).to eq(proposal.body)
            end

            it "traces the action", versioning: true do
              expect(Decidim.traceability)
                .to receive(:create!)
                .with(
                  Decidim::Elections::Answer,
                  user,
                  hash_including(:title, :description, :weight),
                  visibility: "all"
                )
                .and_call_original

              expect { command.call }.to change(Decidim::ActionLog, :count)
              action_log = Decidim::ActionLog.last
              expect(action_log.version).to be_present
              expect(action_log.version.event).to eq "create"
            end
          end
        end
      end
    end
  end
end
