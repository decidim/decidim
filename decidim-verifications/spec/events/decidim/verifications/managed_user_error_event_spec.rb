# frozen_string_literal: true

require "spec_helper"

describe Decidim::Verifications::ManagedUserErrorEvent do
  include_context "when a simple event"
  include Decidim::Core::Engine.routes.url_helpers

  let(:event_name) { "decidim.events.verifications.managed_user_error_event" }
  let(:resource) { create(:conflict) }
  let(:admin_router) { Decidim::EngineRouter.new("decidim_admin", host: resource.current_user.organization.host) }

  let(:resource_title) { resource.current_user.name }
  let(:resource_path) { profile_path(resource.current_user.nickname) }
  let(:resource_url) { profile_url(resource.current_user.nickname, host: resource.current_user.organization.host, port: Capybara.server_port) }
  let(:notification_title) { "The participant <a href=\"#{profile_path(resource.current_user.nickname)}\">#{resource.current_user.name}</a> has tried to verify themselves with the data of another participant (<a href=\"#{profile_path(resource.managed_user.nickname)}\">#{resource.managed_user.name}</a>)." }
  let(:email_subject) { "Failed verification attempt against another participant" }
  let(:email_intro) { "The participant <a href=\"#{profile_url(resource.current_user.nickname, host: resource.current_user.organization.host, port: Capybara.server_port)}\">#{resource.current_user.name}</a> has tried to verify themselves with the data of another participant (<a href=\"#{profile_url(resource.managed_user.nickname, host: resource.current_user.organization.host, port: Capybara.server_port)}\">#{resource.managed_user.name}</a>)." }
  let(:email_outro) { "Check the <a href=\"#{admin_router.conflicts_url}\">Verifications's conflicts list</a> and contact the participant to verify their details and solve the issue." }

  it_behaves_like "a simple event email"
  it_behaves_like "a simple event notification"

  describe "default_i18n_options" do
    it "includes managed_user_name" do
      expect(subject.default_i18n_options[:managed_user_name]).to eq(resource.managed_user.name)
    end

    it "includes managed_user_profile" do
      expect(subject.default_i18n_options[:managed_user_path]).to eq(profile_path(resource.managed_user.nickname))
    end
  end
end
