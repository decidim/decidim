# frozen_string_literal: true

require "spec_helper"

shared_examples "email with logo" do
  context "when organization has a logo" do
    let(:organization_logo) { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }
    let(:organization) { create(:organization, logo: organization_logo) }
    let(:mail) { described_class.event_received(event, event_class_name, resource, user, :follower, extra) }
    let(:logo_path) { Rails.application.routes.url_helpers.rails_representation_path(organization.logo.variant(resize_to_fit: [600, 160]), only_path: true) }

    it "includes organization logo" do
      expect(mail.body).to include(logo_path)
    end

    it "includes organization logo with full link" do
      expect(mail.body).to include("alt=\"#{organization.name}\"")
      expect(mail.body).to match(%r{https{0,1}://#{organization.host}:#{Capybara.server_port}#{logo_path}})
    end
  end
end
