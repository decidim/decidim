# frozen_string_literal: true

require "spec_helper"

describe Decidim::ParticipatoryProcessRoleAssignedEvent do
  include_context "when a simple event"

  let(:resource) { create(:participatory_process) }
  let(:participatory_space) { resource }
  let(:event_name) { "decidim.events.participatory_process.role_assigned" }
  let(:role) { create(:participatory_process_user_role, user:, participatory_process: resource, role: :admin) }
  let(:extra) { { role: } }
  let(:email_subject) { "You have been assigned as #{role} for \"#{resource_title}\"." }
  let(:email_outro) { "You have received this notification because you are #{role} of the \"#{resource_title}\" participatory process." }
  let(:email_intro) { "You have been assigned as #{role} for participatory process \"#{resource_title}\"." }
  let(:notification_title) { "You have been assigned as #{role} for participatory process <a href=\"#{resource_url}\">#{resource_title}</a>." }

  it_behaves_like "a simple event"
  it_behaves_like "a simple event email"
  it_behaves_like "a simple event notification"
end
