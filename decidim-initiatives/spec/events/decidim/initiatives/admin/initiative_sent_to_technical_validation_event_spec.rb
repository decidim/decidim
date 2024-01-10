# frozen_string_literal: true

require "spec_helper"

describe Decidim::Initiatives::Admin::InitiativeSentToTechnicalValidationEvent do
  let(:resource) { create(:initiative) }
  let(:event_name) { "decidim.events.initiatives.admin.initiative_sent_to_technical_validation" }
  let(:admin_initiative_path) { "/admin/initiatives/#{resource.slug}/edit?initiative_slug=#{resource.slug}" }
  let(:admin_initiative_url) { "http://#{organization.host}#{admin_initiative_path}" }
  let!(:initiative_title) { decidim_html_escape(resource_title) }
  let(:email_subject) { "Initiative \"#{decidim_sanitize(resource_title)}\" was sent to technical validation." }
  let(:email_intro) { %(The initiative "#{initiative_title}" has been sent to technical validation. Check it out at <a href="#{admin_initiative_url}">the admin panel</a>) }
  let(:email_outro) { "You have received this notification because you are an admin of the platform." }
  let(:notification_title) { %(The initiative "#{initiative_title}" has been sent to technical validation. Check it out at <a href="#{admin_initiative_path}">the admin panel</a>) }

  include_context "when a simple event"
  it_behaves_like "a simple event"
  it_behaves_like "a simple event email"
  it_behaves_like "a simple event notification"
end
