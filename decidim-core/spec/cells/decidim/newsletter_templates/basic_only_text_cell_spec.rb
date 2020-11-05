# frozen_string_literal: true

require "spec_helper"

describe Decidim::NewsletterTemplates::BasicOnlyTextCell, type: :cell do
  subject do
    cell(content_block.cell, content_block, organization: organization,
                                            newsletter: newsletter,
                                            recipient_user: user,
                                            context: {
                                              controller: controller
                                            }).call
  end

  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization: organization) }
  let(:content_block) { create :content_block, organization: organization, manifest_name: :basic_only_text, scope_name: :newsletter_template, settings: settings }
  let(:newsletter) { create :newsletter, organization: organization }
  let(:body) { ::Faker::Lorem.sentences.join("\n") }
  let(:settings) { { body_en: body } }

  controller Decidim::PagesController

  context "when the organization has no logo setted" do
    it "shows the custom body" do
      expect(subject).to have_text(body)
    end
  end

  context "when the organization has a logo setted" do
    let(:logo) do
      Rack::Test::UploadedFile.new(
        Decidim::Dev.test_file("city.jpeg", "image/jpeg"),
        "image/jpeg"
      )
    end

    before do
      organization.logo = logo
      organization.save!
    end

    it "renders the organization logo" do
      expect(subject.to_s).to include(organization.logo.medium.url)
    end
  end
end
