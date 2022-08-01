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
    let!(:component) { create(:component, manifest_name: :dummy, organization:) }

    let(:english_title) { "English title" }
    let(:spanish_title) { "Spanish title autotranslated" }

    let(:english_comment) { "This is a comment in English" }
    let(:spanish_comment) { "This is a comment in Spanish" }

    let(:english_comment2) { "This was originally in Spanish and translated to English" }
    let(:spanish_comment2) { "This is originally in SPanish, and will be autotranslated into English" }

    let!(:resource) do
      create(
        :dummy_resource,
        component:,
        title: {
          en: english_title,
          machine_translations: {
            es: spanish_title
          }
        }
      )
    end
    let!(:comment) do
      create(
        :comment,
        commentable: resource,
        body: {
          en: english_comment,
          machine_translations: {
            es: spanish_comment
          }
        }
      )
    end
    let!(:multilingual_comment) do
      create(
        :comment,
        commentable: resource,
        body: {
          es: spanish_comment2,
          machine_translations: {
            en: english_comment2
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
        expect(page).to have_content("Mostrar el texto traducido automáticamente")
      end

      it "shows the original English text" do
        # Dummy resource, original in English
        expect(page).to have_content(english_title)
        expect(page).not_to have_content(spanish_title)

        # First comment, original in English
        expect(page).to have_content(english_comment)
        expect(page).not_to have_content(spanish_comment)

        # Last comment, original in Spanish
        expect(page).to have_content(spanish_comment2)
        expect(page).not_to have_content(english_comment2)
      end

      context "when toggling translations" do
        before do
          click_link "Mostrar el texto traducido automáticamente"
        end

        it "shows the translated title" do
          # Dummy resource, original in English
          expect(page).not_to have_content(english_title)
          expect(page).to have_content(spanish_title)

          # First comment, original in English
          expect(page).not_to have_content(english_comment)
          expect(page).to have_content(spanish_comment)

          # Last comment, original in Spanish
          expect(page).to have_content(spanish_comment2)
          expect(page).not_to have_content(english_comment2)
        end
      end
    end

    context "with translated text as priority" do
      let(:translations_priority) { "translation" }

      it "keeps the locale as Spanish" do
        expect(page).to have_content("Procesos")
      end

      it "shows a button to show original text" do
        expect(page).to have_content("Mostrar el texto original")
      end

      it "shows the Spanish texts" do
        # Dummy resource, original in English
        expect(page).not_to have_content(english_title)
        expect(page).to have_content(spanish_title)

        # First comment, original in English
        expect(page).not_to have_content(english_comment)
        expect(page).to have_content(spanish_comment)

        # Last comment, original in Spanish
        expect(page).to have_content(spanish_comment2)
        expect(page).not_to have_content(english_comment2)
      end

      context "when toggling translations" do
        before do
          click_link "Mostrar el texto original"
        end

        it "shows the original values" do
          # Dummy resource, original in English
          expect(page).to have_content(english_title)
          expect(page).not_to have_content(spanish_title)

          # First comment, original in English
          expect(page).to have_content(english_comment)
          expect(page).not_to have_content(spanish_comment)

          # Last comment, original in Spanish
          expect(page).to have_content(spanish_comment2)
          expect(page).not_to have_content(english_comment2)
        end
      end
    end
  end
end
