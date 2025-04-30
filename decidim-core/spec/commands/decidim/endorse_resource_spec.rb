# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe EndorseResource do
    let(:resource) { create(:dummy_resource) }
    let!(:current_user) { create(:user, organization: resource.component.organization) }

    describe "User endorses resource" do
      let(:command) { described_class.new(resource, current_user) }

      context "when in normal conditions" do
        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "creates a new endorsement for the resource" do
          expect do
            command.call
          end.to change(Endorsement, :count).by(1)
        end

        it "notifies all followers of the endorser that the resource has been endorsed" do
          follower = create(:user, organization: resource.organization)
          create(:follow, followable: current_user, user: follower)
          author_follower = create(:user, organization: resource.organization)
          create(:follow, followable: resource.author, user: author_follower)

          expect(Decidim::EventsManager)
            .to receive(:publish)
            .with(
              event: "decidim.events.resource_endorsed",
              event_class: Decidim::ResourceEndorsedEvent,
              resource:,
              followers: [follower],
              extra: {
                endorser_id: current_user.id
              }
            )

          command.call
        end
      end

      context "when the endorsement is not valid" do
        before do
          resource.decidim_component_id = nil
        end

        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:invalid)
        end

        it "does not create a new endorsement for the resource" do
          expect do
            command.call
          end.not_to change(Endorsement, :count)
        end
      end
    end
  end
end
