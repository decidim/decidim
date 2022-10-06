# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Debates
    describe SettingsChangeJob do
      subject { described_class }

      let(:component) { create(:debate).component }
      let(:user) { create :user, organization: component.organization }
      let!(:follow) { create :follow, followable: component.participatory_space, user: }

      let(:previous_settings) do
        { creation_enabled: previously_allowing_creation }
      end
      let(:current_settings) do
        { creation_enabled: currently_allowing_creation }
      end

      context "when debate creation is enabled" do
        let(:previously_allowing_creation) { false }
        let(:currently_allowing_creation) { true }

        it "notifies the space followers about it" do
          expect(Decidim::EventsManager)
            .to receive(:publish)
            .with(
              event: "decidim.events.debates.creation_enabled",
              event_class: Decidim::Debates::CreationEnabledEvent,
              resource: component,
              followers: [user]
            )

          subject.perform_now(component.id, previous_settings, current_settings)
        end
      end

      context "when debate creation is disabled" do
        let(:previously_allowing_creation) { true }
        let(:currently_allowing_creation) { false }

        it "notifies the space followers about it" do
          expect(Decidim::EventsManager)
            .to receive(:publish)
            .with(
              event: "decidim.events.debates.creation_disabled",
              event_class: Decidim::Debates::CreationDisabledEvent,
              resource: component,
              followers: [user]
            )

          subject.perform_now(component.id, previous_settings, current_settings)
        end
      end

      context "when there aren't any changes" do
        let(:previously_allowing_creation) { true }
        let(:currently_allowing_creation) { true }

        it "doesn't notify the space followers about it" do
          expect(Decidim::EventsManager)
            .not_to receive(:publish)

          subject.perform_now(component.id, previous_settings, current_settings)
        end
      end
    end
  end
end
