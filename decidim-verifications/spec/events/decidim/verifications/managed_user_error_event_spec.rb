# frozen_string_literal: true

require "spec_helper"

describe Decidim::Verifications::ManagedUserErrorEvent do
  include_context "when a simple event"

  let(:event_name) { "decidim.events.verifications.managed_user_error_event" }
  let(:resource) { create(:conflict) }
  let(:organization_host) { "#{resource.current_user.organization.host}:#{Capybara.server_port}" }

  let(:resource_title) { resource.current_user.name }
  let(:resource_path) { "/profiles/#{resource.current_user.nickname}" }
  let(:resource_url) { "http://#{organization_host}/profiles/#{resource.current_user.nickname}" }
  let(:notification_title) { "The participant <a href=\"/profiles/#{resource.current_user.nickname}\">#{resource.current_user.name}</a> has tried to verify themself with the data of another participant (<a href=\"/profiles/#{resource.managed_user.nickname}\">#{resource.managed_user.name}</a>)." }
  let(:email_subject) { "Failed verification attempt against another participant" }
  let(:email_intro) { "The participant <a href=\"http://#{organization_host}/profiles/#{resource.current_user.nickname}\">#{resource.current_user.name}</a> has tried to verify themself with the data of another participant (<a href=\"http://#{organization_host}/profiles/#{resource.managed_user.nickname}\">#{resource.managed_user.name}</a>)." }
  let(:email_outro) { "Check the <a href=\"http://#{organization_host}/admin/conflicts\">Verifications's conflicts list</a> and contact the participant to verify their details and solve the issue." }
end
