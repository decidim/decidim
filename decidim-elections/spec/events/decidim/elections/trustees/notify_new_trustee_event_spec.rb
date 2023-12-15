# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Trustees::NotifyNewTrusteeEvent do
  include_context "when a simple event"

  let(:event_name) { "decidim.events.elections.trustees.new_trustee" }
  let(:resource) { create(:participatory_process) }
  let(:participatory_space_title) { resource.title["en"] }
  let(:resource_title) { resource.title["en"] }
  let(:trustee_zone_url) { "http://#{resource.organization.host}/trustee" }
  let(:email_subject) { "You are a trustee for #{participatory_space_title}." }
  let(:email_intro) { "An admin has added you as trustee for #{participatory_space_title}. You should create your public key <a href='#{trustee_zone_url}'>in your trustee zone</a>" }
  let(:email_outro) { "You have received this notification because you have been added as trustee for #{participatory_space_title}." }
  let(:notification_title) { "You have been added to act as a trustee in #{translated(resource.title)} for some elections that will take place in this platform." }

  it_behaves_like "a simple event"
  it_behaves_like "a simple event email"
  it_behaves_like "a simple event notification"
end
