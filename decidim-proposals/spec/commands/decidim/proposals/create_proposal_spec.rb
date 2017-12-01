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
        let!(:proposal) { create :proposal, feature: feature }

        let(:author) { create(:user, organization: organization) }
        let(:admin) {create(:user, :admin, organization: organization)}
        let(:process_admin) {create(:user, :process_admin, organization: feature.organization, participatory_process: feature.participatory_space)}
        let(:user_manager) {create(:user, :user_manager, organization: feature.organization)}

        let(:body) { ::Faker::Lorem.sentences(3).join("\n") }
        let(:title) { ::Faker::Lorem.sentence(3) }
        let(:address) { ::Faker::Address.street_address }
        let(:form_params) do
          {
            "proposal" => {
              "body" => body,
              "title" => title,
              "address" => address
            }
          }
        end

        let(:form) do
          ProposalForm.from_params(
            form_params
          )
        end
        let(:command) { described_class.new(form, author) }

        context "when a proposal is created" do
          it "sends a notification to admins and moderators" do
            binding.pry
            expect(proposal)
              .to receive(:users_to_notify_on_proposal_created)
              .and_return([admin, user_manager, process_admin])

            expect(Decidim::Proposals::Proposal)
              .to receive(:id).at_least(:once).and_return 1

            expect(Decidim::EventsManager)
              .to receive(:publish)
              .with(
                event: "decidim.events.comments.comment_created",
                event_class: Decidim::Proposals::ProposalCreatedEvent,
                resource: proposal,
                recipient_ids: [admin.id, user_manager.id, process_admin.id],
                extra: {
                  comment_id: 1,
                  moderation_event: true
                }
              )

            command.call
          end
        end
      end
    end
  end
end
