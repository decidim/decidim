# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::Admin::ProposalNoteCreatedEvent do
  let(:resource) { create :proposal, title: ::Faker::Lorem.characters(25) }
  let(:resource_title) { translated(resource.title) }
  let(:event_name) { "decidim.events.proposals.admin.proposal_note_created" }
  let(:component) { resource.component }
  let(:admin_proposal_info_path) { "/admin/participatory_processes/#{participatory_space.slug}/components/#{component.id}/manage/proposals/#{resource.id}" }
  let(:admin_proposal_info_url) { "http://#{organization.host}/admin/participatory_processes/#{participatory_space.slug}/components/#{component.id}/manage/proposals/#{resource.id}" }

  include_context "when a simple event"
  it_behaves_like "a simple event"

  describe "email_subject" do
    it "is generated correctly" do
      expect(subject.email_subject).to eq("Someone left a note on proposal #{resource_title}.")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro)
        .to eq(%(Someone has left a note on the proposal "#{resource_title}". Check it out at <a href="#{admin_proposal_info_url}">the admin panel</a>))
    end
  end

  describe "email_outro" do
    it "is generated correctly" do
      expect(subject.email_outro)
        .to eq("You have received this notification because you can valuate the proposal.")
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title)
        .to include(%(Someone has left a note on the proposal <a href="#{resource_path}">#{resource_title}</a>. Check it out at <a href="#{admin_proposal_info_path}">the admin panel</a>))
    end
  end
end
