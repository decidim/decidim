# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe UpdateInitiative do
      let(:form_klass) { Decidim::Initiatives::InitiativeForm }

      context "when valid data" do
        it_behaves_like "update an initiative" do
          context "when the user is the promoter" do
            let(:current_user) { create(:user, organization: initiative.organization) }

            # it "notifies the followers" do
            #   follower = create(:user, :admin, organization: organization)
            #   create(:follow, followable: initiative, user: follower)

            #   expect(Decidim::EventsManager)
            #     .to receive(:publish)
            #     .with(
            #       event: "decidim.events.initiatives.initiative_extended",
            #       event_class: Decidim::Initiatives::ExtendInitiativeEvent,
            #       resource: initiative,
            #       followers: [follower]
            #     )

            #   command.call
            # end

            context "when the signature end time is not modified" do
              let(:signature_end_date) { initiative.signature_end_date }

              it "doesn't notify the followers" do
                expect(Decidim::EventsManager).not_to receive(:publish)

                command.call
              end
            end
          end
        end
      end

      context "when validation failure" do
        let(:organization) { create(:organization) }
        let!(:initiative) { create(:initiative, organization: organization) }
        let!(:form) do
          form_klass
            .from_model(initiative)
            .with_context(current_organization: organization, initiative: initiative)
        end

        let(:command) { described_class.new(initiative, form, initiative.author) }

        it "broadcasts invalid" do
          expect(initiative).to receive(:valid?)
            .at_least(:once)
            .and_return(false)
          expect { command.call }.to broadcast :invalid
        end
      end
    end
  end
end
