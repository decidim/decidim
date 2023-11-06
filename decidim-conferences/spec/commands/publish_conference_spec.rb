# frozen_string_literal: true

require "spec_helper"

describe "Conference can be published", type: :system do
  it_behaves_like "Publicable space", :conference do
    let(:tested) { Decidim::Conferences::Admin::PublishConference }
    let(:follow) { create(:follow, followable: participatory_space, user:) }
    let(:space_options) { { registrations_enabled: true } }

    it "notifies the change" do
      expect(Decidim::EventsManager)
        .to receive(:publish)
        .with(
          event: "decidim.events.conferences.registrations_enabled",
          event_class: Decidim::Conferences::ConferenceRegistrationsEnabledEvent,
          resource: kind_of(Decidim::Conference),
          followers: [follow.user]
        )

      subject.call
    end
  end
end
