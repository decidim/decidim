# frozen_string_literal: true

require "spec_helper"

describe Decidim::Conferences::ConferenceRegistrationsOverPercentageEvent do
  include_context "when a simple event"

  let(:resource) { create(:conference, title: generate_localized_title(:conference_title)) }
  let(:participatory_space) { resource }
  let(:event_name) { "decidim.events.conferences.conference_registrations_over_percentage" }
  let(:extra) { { percentage: 1.1 } }

  it_behaves_like "a simple event"
end
