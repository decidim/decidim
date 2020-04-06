# frozen_string_literal: true

require "spec_helper"

describe Decidim::Initiatives::Admin::InitiativeSentToTechnicalValidationEvent do
  let(:resource) { create :initiative }
  let(:event_name) { "decidim.events.initiatives.admin.initiative_sent_to_technical_validation" }
  let(:admin_initiative_path) { "/admin/initiatives/#{resource.slug}/edit?initiative_slug=#{resource.slug}" }
  let(:admin_initiative_url) { "http://#{organization.host}#{admin_initiative_path}" }

  include_context "when a simple event"
  it_behaves_like "a simple event"

  describe "email_subject" do
    it "is generated correctly" do
      expect(subject.email_subject).to eq("Initiative \"#{resource_title}\" was sent to technical validation.")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro)
        .to eq(%(The initiative "#{resource_title}" has been sent to technical validation. Check it out at <a href="#{admin_initiative_url}">the admin panel</a>))
    end
  end

  describe "email_outro" do
    it "is generated correctly" do
      expect(subject.email_outro)
        .to eq("You have received this notification because you are an admin of the platform.")
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title)
        .to include(%(The initiative "#{resource_title}" has been sent to technical validation. Check it out at <a href="#{admin_initiative_path}">the admin panel</a>))
    end
  end
end
