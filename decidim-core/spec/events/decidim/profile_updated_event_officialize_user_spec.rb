# frozen_string_literal: true

require "spec_helper"

describe Decidim::ProfileUpdatedEvent do
  include_context "when a simple event"

  let(:event_name) { "decidim.events.users.user_officialized" }
  let(:resource) { create(:user) }
  let(:author) { resource }
  let(:email_subject) { "#{resource.name} has been officialized" }
  let(:email_intro) { "Participant #{resource.name} (@#{resource.nickname}) has been officialized." }
  let(:email_outro) { "You have received this notification because you are an administrator of the organization." }
  let(:notification_title) { "Participant #{resource.name} (@#{resource.nickname}) has been officialized." }

  it_behaves_like "a simple event", true
  it_behaves_like "a simple event email"
  it_behaves_like "a simple event notification"
end
