# frozen_string_literal: true

require "spec_helper"

describe "Explore versions", versioning: true, type: :system do
  include_context "with a component"
  let(:manifest_name) { "meetings" }

  let(:meeting_path) do
    decidim_participatory_process_meetings.meeting_path(
      participatory_process_slug: participatory_process.slug,
      component_id: component.id,
      id: meeting.id
    )
  end
  let!(:scope) { create :scope, organization: }
  let!(:meeting) do
    create(
      :meeting,
      :published,
      title: { I18n.locale => "My title" },
      component:,
      # PaperTrail can create an extra version if there's a questionnaire
      questionnaire: nil
    )
  end

  before do
    Decidim.traceability.update!(
      meeting,
      "test suite",
      title: { en: "My updated title" }
    )
    visit meeting_path
  end

  context "when visiting versions index" do
    before do
      click_link "see other versions"
    end

    it "lists all versions" do
      expect(page).to have_link("Version 1")
      expect(page).to have_link("Version 2")
    end

    it "shows the versions count" do
      expect(page).to have_content("VERSIONS\n2")
    end

    it "allows going back to the meeting" do
      click_link "Go back to meeting"
      expect(page).to have_current_path meeting_path
    end

    it "shows the version author and creation date" do
      within ".card--list__item:last-child" do
        expect(page).to have_content("test suite")
        expect(page).to have_content(Time.zone.today.strftime("%d/%m/%Y"))
      end
    end
  end

  context "when showing version" do
    before do
      click_link "see other versions"

      within ".card--list__item:last-child" do
        click_link("Version 2")
      end
    end

    it_behaves_like "accessible page"

    it "shows the version number" do
      expect(page).to have_content("VERSION NUMBER\n2 out of 2")
    end

    it "allows going back to the meeting" do
      click_link "Go back to meeting"
      expect(page).to have_current_path meeting_path
    end

    it "allows going back to the versions list" do
      click_link "Show all versions"
      expect(page).to have_current_path "#{meeting_path}/versions"
    end

    it "shows the version author and creation date" do
      within ".card.extra.definition-data" do
        expect(page).to have_content("test suite")
        expect(page).to have_content(Time.zone.today.strftime("%d/%m/%Y"))
      end
    end

    it "shows the changed attributes" do
      expect(page).to have_content("Changes at")

      within ".diff-for-title-english" do
        expect(page).to have_content("TITLE (ENGLISH)")

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
