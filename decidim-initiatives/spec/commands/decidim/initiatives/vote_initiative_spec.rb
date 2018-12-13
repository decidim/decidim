# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe VoteInitiative do
      let(:initiative) { create(:initiative) }
      let(:current_user) { create(:user, organization: initiative.organization) }

      describe "User votes initiative" do
        let(:command) { described_class.new(initiative, current_user, nil) }

        it "broadcasts ok" do
          expect { command.call }.to broadcast :ok
        end

        it "creates a vote" do
          expect do
            command.call
          end.to change(InitiativesVote, :count).by(1)
        end

        it "increases the vote counter by one" do
          expect do
            command.call
            initiative.reload
          end.to change(initiative, :initiative_votes_count).by(1)
        end

        it "notifies the creation" do
          follower = create(:user, organization: initiative.organization)
          create(:follow, followable: initiative.author, user: follower)

          expect(Decidim::EventsManager)
            .to receive(:publish)
            .with(
              event: "decidim.events.initiatives.initiative_endorsed",
              event_class: Decidim::Initiatives::EndorseInitiativeEvent,
              resource: initiative,
              followers: [follower]
            )

          command.call
        end

        context "when a new milestone is completed" do
          let(:organization) { create(:organization) }
          let(:initiative) do
            create(:initiative,
                   organization: organization,
                   scoped_type: create(
                     :initiatives_type_scope,
                     supports_required: 4,
                     type: create(:initiatives_type, organization: organization)
                   ))
          end

          before do
            create(:initiative_user_vote, initiative: initiative)
            create(:initiative_user_vote, initiative: initiative)
          end

          it "notifies the followers" do
            follower = create(:user, organization: initiative.organization)
            create(:follow, followable: initiative, user: follower)

            expect(Decidim::EventsManager).to receive(:publish)
              .with(kind_of(Hash))

            expect(Decidim::EventsManager)
              .to receive(:publish)
              .with(
                event: "decidim.events.initiatives.milestone_completed",
                event_class: Decidim::Initiatives::MilestoneCompletedEvent,
                resource: initiative,
                recipient_ids: [follower.id],
                extra: { percentage: 75 }
              )

            command.call
          end
        end
      end

      describe "Organization supports initiative" do
        let(:user_group) { create(:user_group) }
        let(:user_group_membership) { create(:user_group_membership, user: current_user, user_group: user_group) }
        let(:command) { described_class.new(initiative, current_user, user_group.id) }

        it "broadcasts ok" do
          expect { command.call }.to broadcast :ok
        end

        it "creates a vote" do
          expect do
            command.call
          end.to change(InitiativesVote, :count).by(1)
        end

        it "does not increases the vote counter by one" do
          command.call
          initiative.reload
          expect(initiative.initiative_votes_count).to be_zero
        end

        it "does not notify the endorsement" do
          expect(Decidim::EventsManager).not_to receive(:publish)
          command.call
        end
      end
    end
  end
end
