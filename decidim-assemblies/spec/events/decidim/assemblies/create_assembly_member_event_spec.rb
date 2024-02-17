# frozen_string_literal: true

require "spec_helper"

describe Decidim::Assemblies::CreateAssemblyMemberEvent do
  include_context "when a simple event"

  let(:resource) { create(:assembly, title: generate_localized_title(:assembly_title)) }
  let(:participatory_space) { resource }
  let(:event_name) { "decidim.events.assemblies.create_assembly_member" }
  let(:email_subject) { "You have been invited to be a member of the #{resource_title} assembly!" }
  let(:email_intro) { %(An admin of the <a href="#{resource_url}">#{resource_title}</a> assembly has added you as one of its members.) }
  let(:email_outro) { %(You have received this notification because you have been invited to an assembly. Check the <a href="#{resource_url}">assembly page</a> to contribute!) }
  let(:notification_title) { %(You have been registered as a member of Assembly <a href="#{resource_path}">#{resource_title}</a>. Check the <a href="#{resource_path}">assembly page</a> to contribute!) }

  it_behaves_like "a simple event"
  it_behaves_like "a simple event email"
  it_behaves_like "a simple event notification"
end
