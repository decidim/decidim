# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe CreateInitiative do
      let(:form_klass) { InitiativeForm }

      context "when happy path" do
        it_behaves_like "create an initiative"
      end

      context "when invalid data" do
        let(:organization) { create(:organization) }
        let(:initiative) { create(:initiative, organization:) }
        let(:form) do
          form_klass
            .from_model(initiative)
            .with_context(
              current_organization: organization,
              initiative_type: initiative.scoped_type.type
            )
        end

        let(:command) { described_class.new(form, initiative.author) }

        it "broadcasts invalid" do
          expect(form).to receive(:title).at_least(:once).and_return nil

          expect { command.call }.to broadcast :invalid
        end
      end

      describe "events" do
        subject do
          described_class.new(form, author)
        end

        let(:scoped_type) { create(:initiatives_type_scope) }
        let(:organization) { scoped_type.type.organization }
        let(:author) { create(:user, organization:) }
        let(:form) do
          form_klass
            .from_params(form_params)
            .with_context(
              current_organization: organization,
              initiative_type: scoped_type.type
            )
        end
        let(:form_params) do
          {
            title: "A reasonable initiative title",
            description: "A reasonable initiative description",
            type_id: scoped_type.type.id,
            signature_type: "online",
            scope_id: scoped_type.scope.id,
            decidim_user_group_id: nil
          }
        end
        let(:follower) { create(:user, organization:) }
        let!(:follow) { create :follow, followable: author, user: follower }

        it "doesn't notify author about committee request" do
          expect(Decidim::EventsManager)
            .not_to receive(:publish)
            .with(
              event: "decidim.events.initiatives.spawn_committee_request",
              event_class: Decidim::Initiatives::SpawnCommitteeRequest,
              resource: Decidim::Initiative.last,
              followers: [author]
            )

          subject.call
        end

        it "notifies the creation" do
          expect(Decidim::EventsManager)
            .to receive(:publish)
            .with(
              event: "decidim.events.initiatives.initiative_created",
              event_class: Decidim::Initiatives::CreateInitiativeEvent,
              resource: kind_of(Decidim::Initiative),
              followers: [follower]
            )

          subject.call
        end
      end
    end
  end
end
