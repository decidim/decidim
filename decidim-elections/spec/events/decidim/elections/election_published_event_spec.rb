# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::ElectionPublishedEvent do
  include_context "when a simple event"

  let(:event_name) { "decidim.events.elections.election_published" }
  let(:resource) { create(:election) }
  let(:participatory_space_title) { resource.participatory_space.title["en"] }
  let(:resource_title) { resource.title["en"] }
  let(:email_subject) { "The #{resource_title} election is now active for #{participatory_space_title}." }
  let(:email_intro) { "The #{resource_title} election is now active for #{participatory_space_title}. You can see it from this page:" }
  let(:email_outro) { "You have received this notification because you are following #{participatory_space_title}. You can stop receiving notifications following the previous link." }
  let(:notification_title) { "The <a href=\"#{resource_path}\">#{resource_title}</a> election is now active for #{participatory_space_title}." }

  it_behaves_like "a simple event"
  it_behaves_like "a simple event email"
  it_behaves_like "a simple event notification"
end
