# frozen_string_literal: true

require "spec_helper"

describe "Newsletters (view in web)", type: :system do
  let(:organization) { newsletter.organization }
  let!(:newsletter) { create :newsletter, :sent }
  let!(:content_block) do
    content_block = Decidim::ContentBlock.find_by(organization:, scope_name: :newsletter_template, scoped_resource_id: newsletter.id)
    content_block.destroy!
    content_block = create(
      :content_block,
      :newsletter_template,
      organization:,
      scoped_resource_id: newsletter.id,
      manifest_name: "image_text_cta",
      settings: {
        body: Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title },
        introduction: Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title },
        cta_text: Decidim::Faker::Localized.word,
        cta_url: I18n.available_locales.index_with { |_locale| Faker::Internet.url }
      }
    )
    content_block
  end

  before do
    switch_to_host organization.host
  end

  describe "accessing the newsletter page" do
    before do
      page.visit decidim.newsletter_path(newsletter)
    end

    it "renders the correct template" do
      within ".content" do
        expect(page).to have_link(translated(content_block.settings.cta_text), href: translated(content_block.settings.cta_url))
      end
    end
  end
end
