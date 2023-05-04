# frozen_string_literal: true

require "spec_helper"

describe "Newsletters (view in web)", type: :system do
  let(:organization) { create(:organization) }
  let!(:newsletter) { create :newsletter, :sent, organization: }
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

    context "when the organization has a primary color defined" do
      let(:organization) { create(:organization, colors: { primary: "#6500ff" }) }
      let(:cta_text) { translated(content_block.settings.cta_text) }

      it "shows the CTA button in correct color" do
        color = find("table.button table td", text: cta_text).native.css_value("background-color")
        expect(color).to eq("rgba(101, 0, 255, 1)")
      end

      it "does not scrub the <style> tag on the page when the organization has a color setting" do
        expect(page).to have_css("style", visible: :hidden)
      end
    end
  end
end
