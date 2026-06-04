# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/has_contextual_help"

describe "Initiatives" do
  let(:organization) { create(:organization) }
  let(:base_initiative) do
    create(:initiative, organization:)
  end

  before do
    switch_to_host(organization.host)
  end

  context "when initiative types and scopes have not been created" do
    it "does not let access to the initiatives" do
      visit decidim_initiatives.initiatives_path(locale: I18n.locale)

      expect(page).to have_current_path(decidim.root_path)
      expect(page).to have_text("Initiatives are not yet configured by an administrator")
    end
  end

  context "when initiative types and scopes have been created" do
    let(:base_initiative) do
      create(:initiative, organization:)
    end

    context "when there are some published initiatives" do
      let!(:initiative) { base_initiative }
      let!(:unpublished_initiative) do
        create(:initiative, :created, organization:)
      end

      before do
        allow(Decidim::Initiatives).to receive(:print_enabled).and_return(true)
      end

      it_behaves_like "shows contextual help" do
        let(:index_path) { decidim_initiatives.initiatives_path(locale: I18n.locale) }
        let(:manifest_name) { :initiatives }
      end

      it_behaves_like "editable content for admins" do
        let(:target_path) { decidim_initiatives.initiatives_path(locale: I18n.locale) }
      end

      context "when requesting the initiatives path" do
        before do
          visit decidim_initiatives.initiatives_path(locale: I18n.locale)
        end

        context "when accessing from the homepage" do
          it "the menu link is shown" do
            visit decidim_initiatives.initiatives_path(locale: I18n.locale)

            within "#menu-bar" do
              expect(page).to have_text("Initiatives")
            end
            expect(page).to have_current_path(decidim_initiatives.initiatives_path(locale: I18n.locale))
          end
        end

        it "lists all the initiatives" do
          within "#initiatives" do
            expect(page).to have_text("1")
            expect(page).to have_text(translated(initiative.title, locale: :en))
            expect(page).to have_no_text(translated(unpublished_initiative.title, locale: :en))
          end
        end

        it "links to the individual initiative page" do
          click_on(translated(initiative.title, locale: :en))
          expect(page).to have_current_path(decidim_initiatives.initiative_path(initiative, locale: I18n.locale))
        end

        it "displays the filter initiative type filter" do
          within ".new_filter[action$='/initiatives']" do
            expect(page).to have_text(/Type/i)
          end
        end

        context "when there is a unique initiative type" do
          let!(:unpublished_initiative) { nil }

          it "does not display the initiative type filter" do
            within ".new_filter[action$='/initiatives']" do
              expect(page).to have_no_text(/Type/i)
            end
          end
        end

        context "when there are only closed initiatives" do
          let!(:closed_initiative) do
            create(:initiative, :discarded, organization:)
          end
          let(:base_initiative) { nil }

          before do
            visit decidim_initiatives.initiatives_path(locale: I18n.locale)
          end

          it "displays a warning" do
            expect(page).to have_text("Currently, there are no open initiatives, but here you can find all the closed initiatives listed.")
          end

          it "shows closed initiatives" do
            within "#initiatives" do
              expect(page).to have_text(translated(closed_initiative.title, locale: :en))
            end
          end
        end
      end

      context "when requesting the initiatives path and initiatives have attachments but the file is not present" do
        let!(:base_initiative) { create(:initiative, :with_photos, organization:) }

        before do
          initiative.attachments.each do |attachment|
            attachment.file.purge
          end
          visit decidim_initiatives.initiatives_path(locale: I18n.locale)
        end

        it "lists all the initiatives without errors" do
          within "#initiatives" do
            expect(page).to have_text("1")
            expect(page).to have_text(translated(initiative.title, locale: :en))
            expect(page).to have_no_text(translated(unpublished_initiative.title, locale: :en))
          end
        end
      end

      context "when it is an initiative with card image enabled" do
        before do
          initiative.type.attachments_enabled = true
          initiative.type.save!

          create(:attachment, attached_to: initiative)

          visit decidim_initiatives.initiatives_path(locale: I18n.locale)
        end

        it "shows the card image" do
          within "#initiative_#{initiative.id}" do
            expect(page).to have_css(".card__grid-img")
          end
        end
      end
    end

    context "when there are more than 20 initiatives" do
      before do
        create_list(:initiative, 21, organization:)
        visit decidim_initiatives.initiatives_path(locale: I18n.locale)
      end

      it "shows the correct initiatives count" do
        expect(page).to have_text("21")
      end
    end
  end
end
