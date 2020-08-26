# frozen_string_literal: true

require "spec_helper"

shared_examples "email with logo" do
  context "when organization has a logo" do
    let(:organization_logo) { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }
    let(:organization) { create(:organization, logo: organization_logo) }
    let(:mail) { described_class.event_received(event, event_class_name, resource, user, :follower, extra) }

    it "includes organization logo" do
      expect(mail.body).to include(organization.logo.medium.url)
    end

    it "includes organization logo with full link" do
      expect(mail.body).to include("alt=\"#{organization.name}\"")
      expect(mail.body).to match(%r{http[s]{0,1}:\/\/#{organization.host}#{organization.logo.medium.url}})
    end
  end
end
