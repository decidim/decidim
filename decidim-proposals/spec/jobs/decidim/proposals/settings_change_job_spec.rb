# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe SettingsChangeJob do
      subject { described_class }

      let(:feature) { create(:proposal_feature) }
      let(:user) { create :user, organization: feature.organization }
      let!(:follow) { create :follow, followable: feature.participatory_space, user: user }

      describe "creation enabled" do
        let(:previous_settings) do
          { creation_enabled: previously_allowing_creation }
        end
        let(:current_settings) do
          { creation_enabled: currently_allowing_creation }
        end

        context "when creation is enabled" do
          let(:previously_allowing_creation) { false }
          let(:currently_allowing_creation) { true }

          it "notifies the space followers about it" do
            expect(Decidim::EventsManager)
              .to receive(:publish)
              .with(
                event: "decidim.events.proposals.creation_enabled",
                event_class: Decidim::Proposals::CreationEnabledEvent,
                resource: feature,
                recipient_ids: [user.id]
              )

            subject.perform_now(feature.id, previous_settings, current_settings)
          end
        end

        context "when creation is not enabled" do
          let(:previously_allowing_creation) { false }
          let(:currently_allowing_creation) { false }

          it "does not notify the space followers about it" do
            expect(Decidim::EventsManager)
              .not_to receive(:publish)

            subject.perform_now(feature.id, previous_settings, current_settings)
          end
        end
      end

      describe "voting enabled" do
        let(:previous_settings) do
          {
            votes_enabled: previously_allowing_votes,
            votes_blocked: previously_blocking_votes
          }
        end
        let(:current_settings) do
          {
            votes_enabled: currently_allowing_votes,
            votes_blocked: currently_blocking_votes
          }
        end

        context "when voting is enabled and unlocked" do
          let(:previously_allowing_votes) { false }
          let(:previously_blocking_votes) { false }
          let(:currently_allowing_votes) { true }
          let(:currently_blocking_votes) { false }

          it "notifies the space followers about it" do
            expect(Decidim::EventsManager)
              .to receive(:publish)
              .with(
                event: "decidim.events.proposals.voting_enabled",
                event_class: Decidim::Proposals::VotingEnabledEvent,
                resource: feature,
                recipient_ids: [user.id]
              )

            subject.perform_now(feature.id, previous_settings, current_settings)
          end
        end

        context "when votes are not enabled" do
          let(:previously_allowing_votes) { true }
          let(:previously_blocking_votes) { false }
          let(:currently_allowing_votes) { false }
          let(:currently_blocking_votes) { false }

          it "does not notify the space followers about it" do
            expect(Decidim::EventsManager)
              .not_to receive(:publish)

            subject.perform_now(feature.id, previous_settings, current_settings)
          end
        end

        context "when votes are blocked" do
          let(:previously_allowing_votes) { false }
          let(:previously_blocking_votes) { false }
          let(:currently_allowing_votes) { true }
          let(:currently_blocking_votes) { true }

          it "does not notify the space followers about it" do
            expect(Decidim::EventsManager)
              .not_to receive(:publish)

            subject.perform_now(feature.id, previous_settings, current_settings)
          end
        end
      end

      describe "endorsing enabled" do
        let(:previous_settings) do
          {
            endorsements_enabled: previously_allowing_endorsements,
            endorsements_blocked: previously_blocking_endorsements
          }
        end
        let(:current_settings) do
          {
            endorsements_enabled: currently_allowing_endorsements,
            endorsements_blocked: currently_blocking_endorsements
          }
        end

        context "when endorsing is enabled and unlocked" do
          let(:previously_allowing_endorsements) { false }
          let(:previously_blocking_endorsements) { false }
          let(:currently_allowing_endorsements) { true }
          let(:currently_blocking_endorsements) { false }

          it "notifies the space followers about it" do
            expect(Decidim::EventsManager)
              .to receive(:publish)
              .with(
                event: "decidim.events.proposals.endorsing_enabled",
                event_class: Decidim::Proposals::EndorsingEnabledEvent,
                resource: feature,
                recipient_ids: [user.id]
              )

            subject.perform_now(feature.id, previous_settings, current_settings)
          end
        end

        context "when endorsements are not enabled" do
          let(:previously_allowing_endorsements) { true }
          let(:previously_blocking_endorsements) { false }
          let(:currently_allowing_endorsements) { false }
          let(:currently_blocking_endorsements) { false }

          it "does not notify the space followers about it" do
            expect(Decidim::EventsManager)
              .not_to receive(:publish)

            subject.perform_now(feature.id, previous_settings, current_settings)
          end
        end

        context "when endorsements are blocked" do
          let(:previously_allowing_endorsements) { false }
          let(:previously_blocking_endorsements) { false }
          let(:currently_allowing_endorsements) { true }
          let(:currently_blocking_endorsements) { true }

          it "does not notify the space followers about it" do
            expect(Decidim::EventsManager)
              .not_to receive(:publish)

            subject.perform_now(feature.id, previous_settings, current_settings)
          end
        end
      end
    end
  end
end
