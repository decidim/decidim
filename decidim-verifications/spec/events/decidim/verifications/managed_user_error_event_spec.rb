# frozen_string_literal: true

require "spec_helper"

describe Decidim::Verifications::ManagedUserErrorEvent do
  include_context "when a simple event"

  let(:event_name) { "decidim.events.verifications.managed_user_error_event" }
  let(:resource) { create :conflict }
  let(:organization_host) { "#{resource.current_user.organization.host}:#{Capybara.server_port}" }

  describe "resource_title" do
    it "is generated correctly" do
      expect(subject.resource_title).to eq(resource.current_user.name)
    end
  end

  describe "resource_path" do
    it "is generated correctly" do
      expect(subject.resource_path).to eq("/profiles/#{resource.current_user.nickname}")
    end
  end

  describe "resource_url" do
    it "is generated correctly" do
      expect(subject.resource_url).to eq("http://#{organization_host}/profiles/#{resource.current_user.nickname}")
    end
  end

  describe "default_i18n_options" do
    it "includes managed_user_name" do
      expect(subject.default_i18n_options[:managed_user_name]).to eq(resource.managed_user.name)
    end

    it "includes managed_user_profile" do
      expect(subject.default_i18n_options[:managed_user_path]).to eq("/profiles/#{resource.managed_user.nickname}")
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title).to eq("The participant <a href=\"/profiles/#{resource.current_user.nickname}\">#{resource.current_user.name}</a> has tried to verify themself with the data of another participant (<a href=\"/profiles/#{resource.managed_user.nickname}\">#{resource.managed_user.name}</a>).")
    end
  end

  describe "email_subject" do
    it "is generated correctly" do
      expect(subject.email_subject).to eq("Failed verification attempt against another participant")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro).to eq("The participant <a href=\"http://#{organization_host}/profiles/#{resource.current_user.nickname}\">#{resource.current_user.name}</a> has tried to verify themself with the data of another participant (<a href=\"http://#{organization_host}/profiles/#{resource.managed_user.nickname}\">#{resource.managed_user.name}</a>).")
    end
  end

  describe "email_outro" do
    it "is generated correctly" do
      expect(subject.email_outro).to eq("Check the <a href=\"http://#{organization_host}/admin/conflicts\">Verifications's conflicts list</a> and contact the participant to verify their details and solve the issue.")
    end
  end
end
