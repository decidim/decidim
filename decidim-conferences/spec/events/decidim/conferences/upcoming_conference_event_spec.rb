# frozen_string_literal: true

require "spec_helper"

describe Decidim::Conferences::UpcomingConferenceEvent do
  let(:resource) { create(:conference, title: generate_localized_title(:conference_title)) }
  let(:event_name) { "decidim.events.conferences.upcoming_conference" }

  include_context "when a simple event"
  it_behaves_like "a simple event"
end
