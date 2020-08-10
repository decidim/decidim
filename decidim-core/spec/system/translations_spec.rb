# frozen_string_literal: true

require "spec_helper"

describe "Translations", type: :system do
  describe "switching locales" do
    let(:translations_priority) { "original" }
    let(:organization) do
      create(
        :organization,
        available_locales: %w(en es),
        enable_machine_translations: true,
        machine_translation_display_priority: translations_priority
      )
    end
    let!(:component) { create(:component, manifest_name: :dummy, organization: organization) }
    let(:english_title) { "English title" }
    let(:spanish_title) { "Spanish title autotranslated" }

    let!(:resource) do
      create(
        :dummy_resource,
        component: component,
        title: {
          en: english_title,
          machine_translations: {
            "es": spanish_title
          }
        }
      )
    end

    let(:resource_path) { resource_locator(resource).path }

    before do
      allow(Decidim.config).to receive(:enable_machine_translations).and_return(true)
      switch_to_host(organization.host)
      visit resource_path

      within_language_menu do
        click_link "Castellano"
      end
    end

    context "with original text as priority" do
      let(:translations_priority) { "original" }

      it "keeps the locale as Spanish" do
        expect(page).to have_content("Procesos")
      end

      it "shows a button to show translated text" do
        expect(page).to have_content("Show automatically-translated text")
      end

      it "shows the original English text" do
        expect(page).to have_content(english_title)
        expect(page).not_to have_content(spanish_title)
      end

      context "when toggling translations" do
        before do
          click_link "Show automatically-translated text"
        end

        it "shows the translated title" do
          expect(page).not_to have_content(english_title)
          expect(page).to have_content(spanish_title)
        end
      end
    end

    context "with translated text as priority" do
      let(:translations_priority) { "translation" }

      it "keeps the locale as Spanish" do
        expect(page).to have_content("Procesos")
      end

      it "shows a button to show original text" do
        expect(page).to have_content("Show original text")
      end

      it "shows the translated Spanish text" do
        expect(page).not_to have_content(english_title)
        expect(page).to have_content(spanish_title)
      end

      context "when toggling translations" do
        before do
          click_link "Show original text"
        end

        it "shows the original title" do
          expect(page).to have_content(english_title)
          expect(page).not_to have_content(spanish_title)
        end
      end
    end
  end
end
