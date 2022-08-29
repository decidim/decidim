# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/has_contextual_help"

describe "Conferences", type: :system do
  let(:organization) { create(:organization) }
  let(:show_statistics) { true }
  let(:base_conference) do
    create(
      :conference,
      organization:,
      description: { en: "Description", ca: "Descripció", es: "Descripción" },
      short_description: { en: "Short description", ca: "Descripció curta", es: "Descripción corta" },
      show_statistics:
    )
  end

  before do
    switch_to_host(organization.host)
  end

  context "when there are no conferences and directly accessing from URL" do
    it_behaves_like "a 404 page" do
      let(:target_path) { decidim_conferences.conferences_path }
    end
  end

  context "when there are no conferences and accessing from the homepage" do
    it "the menu link is not shown" do
      visit decidim.root_path

      within ".main-nav" do
        expect(page).to have_no_content("Conferences")
      end
    end
  end

  context "when the conference does not exist" do
    it_behaves_like "a 404 page" do
      let(:target_path) { decidim_conferences.conference_path(99_999_999) }
    end
  end

  context "when there are some conferences and all are unpublished" do
    before do
      create(:conference, :unpublished, organization:)
      create(:conference, :published)
    end

    context "and directly accessing from URL" do
      it_behaves_like "a 404 page" do
        let(:target_path) { decidim_conferences.conferences_path }
      end
    end

    context "and accessing from the homepage" do
      it "the menu link is not shown" do
        visit decidim.root_path

        within ".main-nav" do
          expect(page).to have_no_content("Conferences")
        end
      end
    end
  end

  context "when there are some published conferences" do
    let!(:conference) { base_conference }
    let!(:promoted_conference) { create(:conference, :promoted, organization:) }
    let!(:unpublished_conference) { create(:conference, :unpublished, organization:) }

    before do
      visit decidim_conferences.conferences_path
    end

    it_behaves_like "shows contextual help" do
      let(:index_path) { decidim_conferences.conferences_path }
      let(:manifest_name) { :conferences }
    end

    context "and accessing from the homepage" do
      it "the menu link is shown" do
        visit decidim.root_path

        within ".main-nav" do
          expect(page).to have_content("Conferences")
          click_link "Conferences"
        end

        expect(page).to have_current_path decidim_conferences.conferences_path
      end
    end

    it "lists all the highlighted conferences" do
      within "#highlighted-conferences" do
        expect(page).to have_content(translated(promoted_conference.title, locale: :en))
        expect(page).to have_selector(".card--full", count: 1)
      end
    end

    it "lists all the conferences" do
      within "#conferences-grid" do
        within "#conferences-grid h3" do
          expect(page).to have_content("2")
        end

        expect(page).to have_content(translated(conference.title, locale: :en))
        expect(page).to have_content(translated(promoted_conference.title, locale: :en))
        expect(page).to have_selector(".card", count: 2)

        expect(page).not_to have_content(translated(unpublished_conference.title, locale: :en))
      end
    end

    it "links to the individual conference page" do
      first(".card__link", text: translated(conference.title, locale: :en)).click

      expect(page).to have_current_path decidim_conferences.conference_path(conference)
    end
  end

  describe "when going to the conference page" do
    let!(:conference) { base_conference }
    let!(:proposals_component) { create(:component, :published, participatory_space: conference, manifest_name: :proposals) }
    let!(:meetings_component) { create(:component, :unpublished, participatory_space: conference, manifest_name: :meetings) }

    before do
      create_list(:proposal, 3, component: proposals_component)
      allow(Decidim).to receive(:component_manifests).and_return([proposals_component.manifest, meetings_component.manifest])

      visit decidim_conferences.conference_path(conference)
    end

    it "shows the details of the given conference" do
      within "div.hero__container" do
        expect(page).to have_content(translated(conference.title, locale: :en))
        expect(page).to have_content(translated(conference.slogan, locale: :en))
        expect(page).to have_content(conference.hashtag)
      end

      within "div.wrapper" do
        expect(page).to have_content(translated(conference.description, locale: :en))
        expect(page).to have_content(translated(conference.short_description, locale: :en))
      end
    end

    context "when the conference has some components" do
      it "shows the components" do
        within ".process-nav" do
          expect(page).to have_content(translated(proposals_component.name, locale: :en).upcase)
          expect(page).to have_no_content(translated(meetings_component.name, locale: :en).upcase)
        end
      end

      it "renders the stats for those components that are visible" do
        within ".section-statistics" do
          expect(page).to have_css(".statistic__title", text: "PROPOSALS")
          expect(page).to have_css(".statistic__number", text: "3")
          expect(page).to have_no_css(".statistic__title", text: "MEETINGS")
          expect(page).to have_no_css(".statistic__number", text: "0")
        end
      end

      context "when the conference stats are not enabled" do
        let(:show_statistics) { false }

        it "doesn't render the stats for those components that are not visible" do
          expect(page).to have_no_css(".statistic__title", text: "PROPOSALS")
          expect(page).to have_no_css(".statistic__number", text: "3")
        end
      end
    end
  end
end
