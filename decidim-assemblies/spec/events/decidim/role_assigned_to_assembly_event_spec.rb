# frozen_string_literal: true

require "spec_helper"

describe Decidim::RoleAssignedToAssemblyEvent do
  include_context "when a simple event"

  let(:resource) { create(:assembly, title: generate_localized_title(:assembly_title)) }
  let(:participatory_space) { resource }
  let(:event_name) { "decidim.events.assembly.role_assigned" }
  let(:role) { create(:assembly_user_role, user:, assembly: resource, role: :admin) }
  let(:extra) { { role: } }
  let(:email_subject) { "You have been assigned as #{role} for \"#{resource_title}\"." }
  let(:email_outro) { "You have received this notification because you are #{role} of the \"#{resource_title}\" assembly." }
  let(:email_intro) { "You have been assigned as #{role} for assembly \"#{resource_title}\"." }
  let(:notification_title) { "You have been assigned as #{role} for assembly <a href=\"#{resource_url}\">#{resource_title}</a>." }

  it_behaves_like "a simple event"
  it_behaves_like "a simple event email"
  it_behaves_like "a simple event notification"
end
