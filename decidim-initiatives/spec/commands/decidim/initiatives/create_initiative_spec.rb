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

        let(:command) { described_class.new(form) }

        it "broadcasts invalid" do
          expect(form).to receive(:title).at_least(:once).and_return nil

          expect { command.call }.to broadcast :invalid
        end
      end

      describe "events" do
        subject do
          described_class.new(form)
        end

        it_behaves_like "fires an ActiveSupport::Notification event", "decidim.initiatives.create_initiative:before" do
          let(:command) { subject }
        end
        it_behaves_like "fires an ActiveSupport::Notification event", "decidim.initiatives.create_initiative:after" do
          let(:command) { subject }
        end

        let(:area) { create(:area, organization:) }
        let(:scoped_type) { create(:initiatives_type_scope) }
        let(:organization) { scoped_type.type.organization }
        let(:author) { create(:user, organization:) }
        let(:form) do
          form_klass
            .from_params(form_params)
            .with_context(
              current_organization: organization,
              current_user: author,
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
            area_id: area.id
          }
        end
        let(:follower) { create(:user, organization:) }
        let!(:follow) { create(:follow, followable: author, user: follower) }

        it "sets the area" do
          subject.call
          expect(Decidim::Initiative.last.area).to eq(area)
        end

        it "does not notify author about committee request" do
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
