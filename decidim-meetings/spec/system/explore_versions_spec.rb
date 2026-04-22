# frozen_string_literal: true

require "spec_helper"

describe "Explore versions", versioning: true do
  include_context "with a component"
  let(:manifest_name) { "meetings" }

  let(:meeting_path) do
    decidim_participatory_process_meetings.meeting_path(
      participatory_process_slug: participatory_process.slug,
      component_id: component.id,
      id: meeting.id
    )
  end
  let!(:scope) { create(:scope, organization:) }
  let!(:meeting) do
    create(
      :meeting,
      :published,
      title: { I18n.locale => "My title" },
      component:,
      # PaperTrail can create an extra version if there is a questionnaire
      questionnaire: nil
    )
  end

  before do
    stub_geocoding_coordinates([meeting.latitude, meeting.longitude])
    Decidim.traceability.update!(
      meeting,
      "test suite",
      title: { en: "My updated title" }
    )
    visit meeting_path
  end

  context "when showing a version of a meeting that is hidden" do
    include_examples "a version of a hidden object" do
      let(:resource_path) { meeting_path }
      let(:hidden_object) { meeting }
    end
  end

  context "when visiting versions index" do
    before do
      click_on "see other versions"
    end

    it "lists all versions" do
      expect(page).to have_link("Version 1 of 2")
      expect(page).to have_link("Version 2 of 2")
    end
  end

  context "when showing version" do
    before do
      click_on "see other versions"
      click_on("Version 2 of 2")
    end

    it_behaves_like "accessible page"

    it "shows the version author and creation date" do
      within ".version__author" do
        expect(page).to have_content("test suite")
        expect(page).to have_content(Time.zone.today.strftime("%d/%m/%Y"))
      end
    end

    it "shows the changed attributes" do
      expect(page).to have_content("Changes at")

      within "#diff-for-title-english" do
        expect(page).to have_content("Title (English)")

        within ".diff > ul > .del" do
          expect(page).to have_content("My title")
        end

        within ".diff > ul > .ins" do
          expect(page).to have_content("My updated title")
        end
      end
    end
  end
end
