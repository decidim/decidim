# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/has_contextual_help"

describe "Initiatives", type: :system do
  let(:organization) { create(:organization) }
  let(:base_initiative) do
    create(:initiative, organization: organization)
  end

  before do
    switch_to_host(organization.host)
  end

  context "when there are some published initiatives" do
    let!(:initiative) { base_initiative }
    let!(:unpublished_initiative) do
      create(:initiative, :created, organization: organization)
    end

    it_behaves_like "shows contextual help" do
      let(:index_path) { decidim_initiatives.initiatives_path }
      let(:manifest_name) { :initiatives }
    end

    it_behaves_like "editable content for admins" do
      let(:target_path) { decidim_initiatives.initiatives_path }
    end

    context "when requesting the initiatives path" do
      before do
        visit decidim_initiatives.initiatives_path
      end

      context "when accessing from the homepage" do
        it "the menu link is shown" do
          visit decidim.root_path

          within ".main-nav" do
            expect(page).to have_content("Initiatives")
            click_link "Initiatives"
          end

          expect(page).to have_current_path(decidim_initiatives.initiatives_path)
        end
      end

      it "lists all the initiatives" do
        within "#initiatives-count" do
          expect(page).to have_content("1")
        end

        within "#initiatives" do
          expect(page).to have_content(translated(initiative.title, locale: :en))
          expect(page).to have_content(initiative.author_name, count: 1)
          expect(page).not_to have_content(translated(unpublished_initiative.title, locale: :en))
        end
      end

      it "links to the individual initiative page" do
        click_link(translated(initiative.title, locale: :en))
        expect(page).to have_current_path(decidim_initiatives.initiative_path(initiative))
      end

      it "displays the filter initiative type filter" do
        within ".new_filter[action$='/initiatives']" do
          expect(page).to have_content(/Type/i)
        end
      end

      context "when there is a unique initiative type" do
        let!(:unpublished_initiative) { nil }

        it "doesn't display the initiative type filter" do
          within ".new_filter[action$='/initiatives']" do
            expect(page).not_to have_content(/Type/i)
          end
        end
      end

      context "when there are only closed initiatives" do
        let!(:closed_initiative) do
          create(:initiative, :discarded, organization: organization)
        end
        let(:base_initiative) { nil }

        before do
          visit decidim_initiatives.initiatives_path
        end

        it "displays a warning" do
          expect(page).to have_content("Currently, there are no open initiatives, but here you can find all the closed initiatives listed.")
        end

        it "shows closed initiatives" do
          within "#initiatives" do
            expect(page).to have_content(translated(closed_initiative.title, locale: :en))
          end
        end
      end
    end

    context "when requesting the initiatives path and initiatives have attachments but the file is not present" do
      let!(:base_initiative) { create(:initiative, :with_photos, organization: organization) }

      before do
        initiative.attachments.each do |attachment|
          attachment.file.purge
        end
        visit decidim_initiatives.initiatives_path
      end

      it "lists all the initiatives without errors" do
        within "#initiatives-count" do
          expect(page).to have_content("1")
        end

        within "#initiatives" do
          expect(page).to have_content(translated(initiative.title, locale: :en))
          expect(page).to have_content(initiative.author_name, count: 1)
          expect(page).not_to have_content(translated(unpublished_initiative.title, locale: :en))
        end
      end
    end

    context "when it is an initiative with card image enabled" do
      before do
        initiative.type.attachments_enabled = true
        initiative.type.save!

        create(:attachment, attached_to: initiative)

        visit decidim_initiatives.initiatives_path
      end

      it "shows the card image" do
        within "#initiative_#{initiative.id}" do
          expect(page).to have_selector(".card__image")
        end
      end
    end
  end
end
