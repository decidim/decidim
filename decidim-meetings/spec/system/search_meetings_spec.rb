# frozen_string_literal: true

require "spec_helper"

describe "Search meetings" do
  include ActionView::Helpers::SanitizeHelper

  include_context "with a component"
  let(:manifest_name) { "meetings" }

  context "when meetings are published" do
    let!(:searchables) { create_list(:meeting, 3, :published, component:) }
    let!(:term) { strip_tags(searchables.first.title["en"]).split.sample }

    include_examples "searchable results"
  end

  context "when there are more meetings than the pagination" do
    let!(:meetings) { create_list(:meeting, 35, :published, component:) }

    it "views them all" do
      visit_component

      within("main") do
        expect(page).to have_text("35 meetings")
      end

      within "main nav" do
        expect(page).to have_text("Next")
      end
    end
  end

  context "when rendering the results in the search page" do
    let(:search_term) { "doggo" }
    let(:search_path) { decidim.search_path(term: search_term, filter: { with_resource_type: "Decidim::Meetings::Meeting" }) }
    let(:meeting_taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:, skip_injection: true) }
    let(:child_meeting_taxonomy) { create(:taxonomy, parent: meeting_taxonomy, organization:, skip_injection: true) }
    let!(:meeting_taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: meeting_taxonomy) }
    let!(:child_meeting_taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: child_meeting_taxonomy) }
    let!(:meeting) do
      create(
        :meeting,
        :published,
        component:,
        taxonomies: [meeting_taxonomy, child_meeting_taxonomy],
        title: { en: "A doggo meeting with taxonomies" }
      )
    end

    before do
      visit search_path
    end

    it "renders the meeting title as a link to the meeting page" do
      expect(page).to have_link(translated(meeting.title), href: Decidim::ResourceLocatorPresenter.new(meeting).path)
    end

    it "renders the taxonomies of the meeting" do
      within "a.card__list#meetings__meeting_#{meeting.id}" do
        expect(page).to have_css(".card__list-metadata", text: translated(meeting_taxonomy.name))
        expect(page).to have_css(".card__list-metadata", text: translated(child_meeting_taxonomy.name))
      end
    end

    it "escapes the meeting title instead of rendering it" do
      malicious = create(:meeting, :published, component:, title: { en: 'A doggo <script>alert("XSS")</script> meeting' })

      visit search_path

      expect(page).to have_css(".card__list-title", text: '<script>alert("XSS")</script>')
      expect(page).to have_no_css(".card__list-title script")
      expect(page).to have_link(translated(malicious.title), href: Decidim::ResourceLocatorPresenter.new(malicious).path)
    end
  end

  context "when meetings are not published" do
    let!(:searchables) { create_list(:meeting, 3, component:) }
    let!(:term) { strip_tags(searchables.first.title["en"]).split.sample }
    let(:organization) { create(:organization) }

    before do
      switch_to_host(organization.host)
      visit decidim.root_path
    end

    context "when searching for indexed searchables" do
      it "does not contain these searchables" do
        within "#form-search_topbar" do
          fill_in "term", with: term
          click_on
        end

        expect(page).to have_current_path decidim.search_path, ignore_query: true
        expect(page).to have_text(%(results for the search: "#{term}"))
        expect(page).to have_css(".filter-search.filter-container")
        expect(page.find("#search-count h2").text.to_i).to eq(0)
      end
    end
  end
end
