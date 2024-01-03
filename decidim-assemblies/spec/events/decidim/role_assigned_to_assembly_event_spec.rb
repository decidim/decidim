# frozen_string_literal: true

require "spec_helper"

describe Decidim::RoleAssignedToAssemblyEvent do
  include_context "when a simple event"

  let(:resource) { create(:assembly, title: { en: "It is my assembly" }) }
  let(:event_name) { "decidim.events.assembly.role_assigned" }
  let(:role) { create(:assembly_user_role, user:, assembly: resource, role: :admin) }
  let(:extra) { { role: } }
  let(:email_subject) { "You have been assigned as #{role} for \"#{resource.title["en"]}\"." }
  let(:email_outro) { "You have received this notification because you are #{role} of the \"#{resource.title["en"]}\" assembly." }
  let(:email_intro) { "You have been assigned as #{role} for assembly \"#{resource.title["en"]}\"." }
  let(:notification_title) { "You have been assigned as #{role} for assembly <a href=\"#{resource_url}\">#{resource.title["en"]}</a>." }

  it_behaves_like "a simple event"
  it_behaves_like "a simple event email"
  it_behaves_like "a simple event notification"
end
