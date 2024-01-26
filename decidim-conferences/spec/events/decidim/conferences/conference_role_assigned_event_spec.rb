# frozen_string_literal: true

require "spec_helper"

describe Decidim::Conferences::ConferenceRoleAssignedEvent do
  include_context "when a simple event"

  let(:resource) { create(:conference, title: { en: "It is my conference" }) }
  let(:event_name) { "decidim.events.conferences.role_assigned" }
  let(:role) { create(:conference_user_role, user:, conference: resource, role: :admin) }
  let(:extra) { { role: } }
  let(:email_subject) { "You have been assigned as #{role} for \"#{resource.title["en"]}\"." }
  let(:email_outro) { "You have received this notification because you are #{role} of the \"#{resource.title["en"]}\" conference." }
  let(:email_intro) { "You have been assigned as #{role} for conference \"#{resource.title["en"]}\"." }
  let(:notification_title) { "You have been assigned as #{role} for conference <a href=\"#{resource_url}\">#{resource.title["en"]}</a>." }

  it_behaves_like "a simple event"
  it_behaves_like "a simple event email"
  it_behaves_like "a simple event notification"
end
