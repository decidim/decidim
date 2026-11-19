# frozen_string_literal: true

require "spec_helper"

describe Decidim::NewsletterTemplates::BasicOnlyTextCell, type: :cell do
  subject do
    cell(content_block.cell, content_block, organization:,
                                            newsletter:,
                                            recipient_user: user,
                                            context: {
                                              controller:
                                            }).call
  end

  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization:) }
  let(:content_block) { create(:content_block, organization:, manifest_name: :basic_only_text, scope_name: :newsletter_template, settings:) }
  let(:newsletter) { create(:newsletter, organization:) }
  let(:body) { Faker::Lorem.sentences.join("\n") }
  let(:settings) { { body_en: body } }
  let(:logo_url) { Rails.application.routes.url_helpers.rails_representation_path(organization.logo.variant(resize_to_fit: [600, 160]), host: organization.host) }
  let(:root_url) { Decidim::Core::Engine.routes.url_helpers.root_url(host: organization.host, port: Capybara.server_port) }
  let(:origin) { "http://#{organization.host}:#{Capybara.server_port}" }

  controller Decidim::PagesController

  context "when the organization has no logo set" do
    it "shows the custom body" do
      expect(subject).to have_text(body)
    end
  end

  context "when the body contains a relative image" do
    let(:body) { %(<p>Hello</p><img src="/rails/active_storage/blobs/redirect/12345.JPG" alt="image" />) }

    it "prefixes the image URL with the host origin" do
      expect(subject.to_s).to include(%(<img src="#{origin}/rails/active_storage/blobs/redirect/12345.JPG" alt="image"))
    end

    it "does not insert the locale in image URLs" do
      expect(subject.to_s).not_to match(%r{/[a-z]{2}/rails/active_storage})
    end
  end

  context "when the organization has a logo set" do
    let(:logo) do
      Decidim::Dev.test_file("city.jpeg", "image/jpeg")
    end

    before do
      organization.logo = logo
      organization.save!
    end

    it "renders the organization logo" do
      expect(subject.to_s).to include(logo_url)
    end

    it "renders the URL to to the application" do
      expect(subject).to have_css(".decidim-bar a[href='#{root_url}'] img")
    end
  end
end
