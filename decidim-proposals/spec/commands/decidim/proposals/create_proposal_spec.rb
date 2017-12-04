# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe CreateProposal do
      let(:form_klass) { ProposalForm }

      it_behaves_like "create a proposal", true
      describe "call" do
        let(:form_klass) { ProposalForm }
        it_behaves_like "create a proposal", true
        let(:organization) { create(:organization) }
        let(:participatory_process) { create(:participatory_process, organization: organization) }
        let(:feature) { create :feature, manifest_name: :proposals, participatory_space: participatory_process }
        let(:author) { create(:user, organization: organization) }
        let(:admin) {create(:user, :admin, organization: organization)}
        let(:process_admin) {create(:user, :process_admin, organization: feature.organization, participatory_process: feature.participatory_space)}
        let(:user_manager) {create(:user, :user_manager, organization: feature.organization)}

        let(:body) { ::Faker::Lorem.sentences(3).join("\n") }
        let(:title) { ::Faker::Lorem.sentence(3) }
        let(:form_params) do
          {
            "proposal" => {
              "body" => body,
              "title" => title,
            }
          }
        end

        let(:form) do
          ProposalForm.from_params(
            form_params
          )
        end
        let(:command) { described_class.new(form, author) }

        it "creates a new proposal" do
            expect(Proposal).to receive(:create!).with(
              author: author,
              body: body,
              title: title
            ).and_call_original

            expect do
              command.call
            end.to change { Proposal.count }.by(1)
          end

        context "when a proposal is created" do
          before do
            @proposal = create(:proposal, author: author, feature: feature)
          end
          it "sends a notification to admins and moderators" do
            binding.pry
            expect(@proposal.users_to_notify_on_proposal_created)
              .to eq([admin, user_manager, process_admin])

            # expect(Decidim::Proposals::Proposal)
            #   .to receive(:id).at_least(:once).and_return 1

            # expect(Decidim::EventsManager)
            #   .to receive(:publish)
            #   .with(
            #     event: "decidim.events.proposals.proposal_created",
            #     event_class: Decidim::Proposals::ProposalCreatedEvent,
            #     resource: @proposal,
            #     recipient_ids: [admin.id, user_manager.id, process_admin.id],
            #     extra: {
            #       comment_id: 1,
            #       moderation_event: true
            #     }
            #   )

            # command.call
          end
        end
      end
    end
  end
end
