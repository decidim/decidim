# frozen_string_literal: true

require "spec_helper"

describe "Explore versions", versioning: true, type: :feature do
  include_context "with a feature"
  let(:manifest_name) { "accountability" }

  let(:result_path) do
    decidim_participatory_process_accountability.result_path(
      participatory_process_slug: participatory_process.slug,
      feature_id: feature.id,
      id: result.id
    )
  end
  let!(:scope) { create :scope, organization: organization }
  let!(:result) do
    create(
      :result,
      progress: 25.0,
      feature: feature
    )
  end

  before do
    Decidim.traceability.update!(
      result,
      "test suite",
      progress: 50.0
    )
    visit result_path
  end

  context "when visiting versions index" do
    before do
      click_link "Show all versions"
    end

    it "lists all versions" do
      expect(page).to have_link("Version 1")
      expect(page).to have_link("Version 2")
    end

    it "shows the versions count" do
      expect(page).to have_content("VERSIONS 2")
    end

    it "allows going back to the result" do
      click_link "Go back to result"
      expect(page).to have_current_path result_path
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
      click_link "Show all versions"

      within ".card--list__item:last-child" do
        click_link("Version 2")
      end
    end

    it "shows the version number" do
      expect(page).to have_content("VERSION NUMBER 2 out of 2")
    end

    it "allows going back to the result" do
      click_link "Go back to result"
      expect(page).to have_current_path result_path
    end

    it "allows going back to the versions list" do
      click_link "Show all versions"
      expect(page).to have_current_path result_path + "/versions"
    end

    it "shows the version author and creation date" do
      within ".card.extra.definition-data" do
        expect(page).to have_content("test suite")
        expect(page).to have_content(Time.zone.today.strftime("%d/%m/%Y"))
      end
    end

    it "shows the changed attributes" do
      expect(page).to have_content("PROGRESS")

      within ".card.diff .removal" do
        expect(page).to have_content("25.00%")
      end

      within ".card.diff .addition" do
        expect(page).to have_content("50.00%")
      end
    end
  end
end
