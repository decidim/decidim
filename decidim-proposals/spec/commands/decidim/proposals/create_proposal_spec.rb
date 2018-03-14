# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe CreateProposal do
      let(:form_klass) { ProposalForm }

      it_behaves_like "create a proposal", true

      describe "events" do
        subject do
          described_class.new(form, author)
        end

        let(:component) { create(:proposal_component) }
        let(:organization) { component.organization }
        let(:form) do
          form_klass.from_params(
            form_params
          ).with_context(
            current_organization: organization,
            current_participatory_space: component.participatory_space,
            current_component: component
          )
        end
        let(:form_params) do
          {
            title: "A reasonable proposal title",
            body: "A reasonable proposal body",
            address: nil,
            has_address: false,
            attachment: nil,
            user_group_id: nil
          }
        end
        let(:author) { create(:user, organization: organization) }
        let(:follower) { create(:user, organization: organization) }
        let!(:follow) { create :follow, followable: author, user: follower }

        it "notifies the change" do
          other_follower = create(:user, organization: organization)
          create(:follow, followable: component.participatory_space, user: follower)
          create(:follow, followable: component.participatory_space, user: other_follower)

          expect(Decidim::EventsManager)
            .to receive(:publish)
            .with(
              event: "decidim.events.proposals.proposal_created",
              event_class: Decidim::Proposals::CreateProposalEvent,
              resource: kind_of(Decidim::Proposals::Proposal),
              recipient_ids: [follower.id]
            ).ordered

          expect(Decidim::EventsManager)
            .to receive(:publish)
            .with(
              event: "decidim.events.proposals.proposal_created",
              event_class: Decidim::Proposals::CreateProposalEvent,
              resource: kind_of(Decidim::Proposals::Proposal),
              recipient_ids: [other_follower.id],
              extra: {
                participatory_space: true
              }
            ).ordered

          subject.call
        end
      end
    end
  end
end
