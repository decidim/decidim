# frozen_string_literal: true

require "spec_helper"

describe Decidim::Assemblies::CreateAssemblyMemberEvent do
  let(:assembly) { create :assembly }
  let(:resource) { assembly }
  let(:event_name) { "decidim.events.assemblies.create_assembly_member" }
  let(:assembly_title) { translated(assembly.title) }

  include_context "when a simple event"
  it_behaves_like "a simple event"

  describe "email_subject" do
    it "is generated correctly" do
      expect(subject.email_subject).to eq("You have been invited to be a member of the #{assembly_title} assembly!")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro)
        .to eq(%(An admin of the <a href="#{resource_url}">#{assembly_title}</a> assembly has added you as one of its members.))
    end
  end

  describe "email_outro" do
    it "is generated correctly" do
      expect(subject.email_outro)
        .to eq(%(You have received this notification because you have been invited to an assembly. Check the <a href="#{resource_path}">assembly page</a> to contribute!))
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title)
        .to include(%(You have been registered as a member of Assembly <a href="#{resource_path}">#{assembly_title}</a>. Check the <a href="#{resource_path}">assembly page</a> to contribute!))
    end
  end
end
