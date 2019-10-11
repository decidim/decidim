# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/has_contextual_help"

describe "Conferences", type: :system do
  let(:organization) { create(:organization) }
  let(:show_statistics) { true }
  let(:base_conference) do
    create(
      :conference,
      organization: organization,
      description: { en: "Description", ca: "Descripció", es: "Descripción" },
      short_description: { en: "Short description", ca: "Descripció curta", es: "Descripción corta" },
      show_statistics: show_statistics
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
      create(:conference, :unpublished, organization: organization)
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
    let!(:promoted_conference) { create(:conference, :promoted, organization: organization) }
    let!(:unpublished_conference) { create(:conference, :unpublished, organization: organization) }

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
        expect(page).to have_selector("article.card--full", count: 1)
      end
    end

    it "lists all the conferences" do
      within "#conferences-grid" do
        within "#conferences-grid h2" do
          expect(page).to have_content("2")
        end

        expect(page).to have_content(translated(conference.title, locale: :en))
        expect(page).to have_content(translated(promoted_conference.title, locale: :en))
        expect(page).to have_selector("article.card", count: 2)

        expect(page).not_to have_content(translated(unpublished_conference.title, locale: :en))
      end
    end

    it "links to the individual conference page" do
      click_link(translated(conference.title, locale: :en))

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

      it "shows the stats for those components" do
        within ".process_stats" do
          expect(page).to have_content("3 PROPOSALS")
          expect(page).not_to have_content("0 MEETINGS")
        end
      end

      context "when the conference stats are not enabled" do
        let(:show_statistics) { false }

        it "the stats for those components are not visible" do
          expect(page).not_to have_content("3 PROPOSALS")
        end
      end
    end
  end

  describe "custom link" do
    let!(:custom_link_name) do
      {
        en: "decidim",
        es: "decidim",
        ca: "decidim"
      }
    end
    let!(:custom_link_url) { "https://decidim.org" }

    context "when there is no custom link" do
      let!(:conference) { create(:conference, :published, organization: organization) }

      before do
        visit decidim_conferences.conferences_path
        click_link "More info"
      end

      it "displays a custom link" do
        expect(page).not_to have_link(custom_link_name[:en], href: custom_link_url)
      end
    end

    context "when there is a custom link" do
      let!(:conference) do
        create(:conference,
               :with_custom_link,
               :published,
               custom_link_name: custom_link_name,
               custom_link_url: custom_link_url,
               organization: organization)
      end

      before do
        visit decidim_conferences.conferences_path
        click_link "More info"
      end

      it "displays a custom link" do
        expect(page).to have_link(custom_link_name[:en], href: custom_link_url)
      end
    end
  end
end
