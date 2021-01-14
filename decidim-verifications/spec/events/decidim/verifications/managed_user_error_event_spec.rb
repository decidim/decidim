# frozen_string_literal: true

require "spec_helper"

describe Decidim::Verifications::ManagedUserErrorEvent do
  include_context "when a simple event"

  let(:event_name) { "decidim.events.verifications.managed_user_error_event" }
  let(:resource) { create :conflict }

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
      expect(subject.resource_url).to eq("http://#{resource.current_user.organization.host}/profiles/#{resource.current_user.nickname}")
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
      expect(subject.notification_title).to eq("The participant <a href=\"/profiles/#{resource.current_user.nickname}\">#{resource.current_user.name}</a> has tried to verify herself with the data of the managed participant <a href=\"/profiles/#{resource.managed_user.nickname}\">#{resource.managed_user.name}</a>")
    end
  end
end
