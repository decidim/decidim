# frozen_string_literal: true

require "spec_helper"

describe Decidim::Conferences::UpdateConferenceEvent do
  let(:resource) { create :conference }
  let(:event_name) { "decidim.events.conferences.conference_updated" }

  include_context "when a simple event"
  it_behaves_like "a simple event"
end
