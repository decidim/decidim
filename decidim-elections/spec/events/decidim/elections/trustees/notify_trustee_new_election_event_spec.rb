# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Trustees::NotifyTrusteeNewElectionEvent do
  include_context "when a simple event"

  let(:event_name) { "decidim.events.elections.trustees.new_election" }
  let(:resource) { create(:election) }
  let(:resource_title) { resource.title["en"] }
  let(:email_subject) { "You are a trustee for the #{resource_title} election." }
  let(:email_intro) { "You got added as a trustee for the #{resource_title} election." }
  let(:email_outro) { "You have received this notification because you have been added as trustee for the #{resource_title} election." }
  let(:notification_title) { "You have been selected as a Trustee in Election <a href=\"#{resource_path}\">#{resource_title}.</a> Please, do the key ceremony to set up the election." }

  it_behaves_like "a simple event"
  it_behaves_like "a simple event email"
  it_behaves_like "a simple event notification"
end
