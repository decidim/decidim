# frozen_string_literal: true

require "spec_helper"

describe Decidim::Conferences::ConferenceRoleAssignedEvent do
  include_context "when a simple event"

  let(:resource) { create(:conference, title: generate_localized_title(:conference_title)) }
  let(:participatory_space) { resource }
  let(:event_name) { "decidim.events.conferences.role_assigned" }
  let(:role) { create(:conference_user_role, user:, conference: resource, role: :admin) }
  let(:extra) { { role: } }
  let(:email_subject) { "You have been assigned as #{role} for \"#{resource_title}\"." }
  let(:email_outro) { "You have received this notification because you are #{role} of the \"#{resource_title}\" conference." }
  let(:email_intro) { "You have been assigned as #{role} for conference \"#{resource_title}\"." }
  let(:notification_title) { "You have been assigned as #{role} for conference <a href=\"#{resource_url}\">#{resource_title}</a>." }

  it_behaves_like "a simple event"
  it_behaves_like "a simple event email"
  it_behaves_like "a simple event notification"
end
