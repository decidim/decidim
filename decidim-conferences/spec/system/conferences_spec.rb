# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/has_contextual_help"

describe "Conferences" do
  let(:organization) { create(:organization) }
  let(:show_statistics) { true }
  let(:description) { { en: "Description", ca: "Descripció", es: "Descripción" } }
  let(:short_description) { { en: "Short description", ca: "Descripció curta", es: "Descripción corta" } }
  let(:base_conference) do
    create(
      :conference,
      organization:,
      description:,
      short_description:,
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
    let!(:menu_content_block) { create(:content_block, organization:, manifest_name: :global_menu, scope_name: :homepage) }

    it "the menu link is not shown" do
      visit decidim.root_path

      within "#home__menu" do
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
      let!(:menu_content_block) { create(:content_block, organization:, manifest_name: :global_menu, scope_name: :homepage) }

      it "the menu link is not shown" do
        visit decidim.root_path

        within "#home__menu" do
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
      let!(:menu_content_block) { create(:content_block, organization:, manifest_name: :global_menu, scope_name: :homepage) }

      it "the menu link is shown" do
        visit decidim.root_path

        within "#home__menu" do
          click_on "Conferences"
        end

        expect(page).to have_current_path decidim_conferences.conferences_path
      end
    end

    it "lists all the highlighted conferences" do
      within "#highlighted-conferences" do
        expect(page).to have_content(translated(promoted_conference.title, locale: :en))
        expect(page).to have_css("[id^='conference_highlight']", count: 1)
      end
    end

    it "lists all the conferences" do
      within "#conferences-grid" do
        within "#conferences-grid h2" do
          expect(page).to have_content("2")
        end

        expect(page).to have_content(translated(conference.title, locale: :en))
        expect(page).to have_content(translated(promoted_conference.title, locale: :en))
        expect(page).to have_css("[id^='conference']", count: 2)

        expect(page).to have_no_content(translated(unpublished_conference.title, locale: :en))
      end
    end

    it "links to the individual conference page" do
      within "#conferences-grid" do
        first("[id^='conference']", text: translated(conference.title, locale: :en)).click

        expect(page).to have_current_path decidim_conferences.conference_path(conference)
      end
    end
  end

  it_behaves_like "followable space content for users" do
    let(:conference) { base_conference }
    let!(:user) { create(:user, :confirmed, organization:) }
    let(:followable) { conference }
    let(:followable_path) { decidim_conferences.conference_path(conference) }
  end

  describe "when going to the conference page" do
    let!(:conference) { base_conference }
    let!(:proposals_component) { create(:component, :published, participatory_space: conference, manifest_name: :proposals) }
    let!(:meetings_component) { create(:meeting_component, :unpublished, participatory_space: conference) }

    before do
      create_list(:proposal, 3, component: proposals_component)
      allow(Decidim).to receive(:component_manifests).and_return([proposals_component.manifest, meetings_component.manifest])

      visit decidim_conferences.conference_path(conference)
    end

    it "has a sidebar" do
      expect(page).to have_css(".conference__nav-container")
    end

    describe "conference venues" do
      before do
        meetings.empty?
        allow(Decidim).to receive(:address).and_return("foo bar")

        visit decidim_conferences.conference_path(conference)
      end

      context "when the meeting component is not published" do
        let!(:meetings_component) { create(:meeting_component, :unpublished, participatory_space: conference) }
        let!(:meetings) { create_list(:meeting, 3, :published, component: meetings_component) }

        it "does not show the venues" do
          expect(page).to have_no_content("Conference Venues")
        end
      end

      context "when the meeting component is published" do
        let!(:meetings_component) { create(:meeting_component, :published, participatory_space: conference) }

        context "when there are published meetings" do
          let!(:meetings) { create_list(:meeting, 3, :published, component: meetings_component) }

          it "does show the venues" do
            expect(page).to have_content("Conference Venues")
          end
        end

        context "when there are moderated meetings" do
          let!(:meetings) { create_list(:meeting, 3, :moderated, :published, component: meetings_component) }

          it "does not show the venues" do
            expect(page).to have_no_content("Conference Venues")
          end
        end

        context "when there are no published meetings" do
          let!(:meetings) { create_list(:meeting, 3, published_at: nil, component: meetings_component) }

          it "does not show the venues" do
            expect(page).to have_no_content("Conference Venues")
          end
        end

        context "when there are no visible meetings" do
          let!(:meetings) { create_list(:meeting, 3, :published, private_meeting: true, transparent: false, component: meetings_component) }

          it "does not show the venues" do
            expect(page).to have_no_content("Conference Venues")
          end
        end

        context "when there are visible meetings" do
          let!(:meetings) { create_list(:meeting, 3, :published, private_meeting: true, transparent: true, component: meetings_component) }

          it "does not show the venues" do
            expect(page).to have_content("Conference Venues")
          end
        end
      end
    end

    it "shows the details of the given conference" do
      within "[data-conference-hero]", match: :first do
        expect(page).to have_content(translated(conference.title, locale: :en))
        expect(page).to have_content(translated(conference.slogan, locale: :en))
        expect(page).to have_content(conference.hashtag)
      end

      expect(page).to have_content(translated(conference.description, locale: :en))
      expect(page).to have_content(translated(conference.short_description, locale: :en))
    end

    it_behaves_like "has embedded video in description", :description
    it_behaves_like "has embedded video in description", :short_description

    context "when the conference has some components" do
      it "shows the components" do
        within ".conference__nav" do
          expect(page).to have_content(decidim_escape_translated(proposals_component.name))
          expect(page).to have_no_content(decidim_escape_translated(meetings_component.name))
        end
      end

      it "renders the stats for those components that are visible" do
        within all("[data-statistic]")[0] do
          expect(page).to have_css(".statistic__title", text: "Proposals")
          expect(page).to have_css(".statistic__number", text: "3")
          expect(page).to have_no_css(".statistic__title", text: "Meetings")
          expect(page).to have_no_css(".statistic__number", text: "0")
        end
      end

      context "when the conference stats are not enabled" do
        let(:show_statistics) { false }

        it "does not render the stats for those components that are not visible" do
          expect(page).to have_no_css(".statistic__title", text: "Proposals")
          expect(page).to have_no_css(".statistic__number", text: "3")
        end
      end

      context "when the conference has multiple meetings components" do
        let!(:meetings_component) { create(:component, :published, participatory_space: conference, manifest_name: :meetings) }
        let!(:other_meetings_component) { create(:component, :published, participatory_space: conference, manifest_name: :meetings) }

        it "show meeting venues" do
          create(:meeting, :published, :online, address: "", location_hints: nil, location: "", component: meetings_component)
          create(:meeting, :published, :in_person, address: "", location_hints: nil, location: "", component: other_meetings_component)
          create_list(:meeting, 3, :published, :in_person, component: meetings_component)

          visit decidim_conferences.conference_path(conference)

          expect(page).to have_css(".conference__map-address", count: 3)
        end
      end
    end
  end

  describe "when the conference has no components" do
    let!(:conference) { base_conference }

    before do
      visit decidim_conferences.conference_path(conference)
    end

    it "has no sidebar" do
      expect(page).to have_no_css(".conference__nav-container")
    end
  end
end
