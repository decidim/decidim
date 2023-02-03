# frozen_string_literal: true

require "spec_helper"

describe "Explore versions", versioning: true, type: :system do
  include_context "with a component"
  let(:manifest_name) { "accountability" }

  let(:result_path) do
    decidim_participatory_process_accountability.result_path(
      participatory_process_slug: participatory_process.slug,
      component_id: component.id,
      id: result.id
    )
  end
  let!(:scope) { create :scope, organization: }
  let!(:result) do
    create(
      :result,
      progress: 25.0,
      component:
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
      click_link "see other versions"
    end

    it "lists all versions" do
      expect(page).to have_link("Version 1 of 2")
      expect(page).to have_link("Version 2 of 2")
    end
  end

  context "when showing version" do
    before do
      click_link "see other versions"
      click_link "Version 2 of 2"
    end

    it "allows going back to the result" do
      click_link "Go back to result"
      expect(page).to have_current_path result_path
    end

    it "allows going back to the versions list" do
      skip "REDESIGN_PENDING: Once redesigned this page will contain a call to the versions_list cell with links to each one"

      click_link "Show all versions"
      expect(page).to have_current_path "#{result_path}/versions"
    end

    it "shows the version author and creation date" do
      skip_unless_redesign_enabled("this test pass using redesigned version_author cell")

      within ".version__author" do
        expect(page).to have_content("test suite")
        expect(page).to have_content(Time.zone.today.strftime("%d/%m/%Y"))
      end
    end

    it "shows the changed attributes" do
      expect(page).to have_content("Changes at")

      within "#diff-for-progress" do
        expect(page).to have_content("Progress")

        within ".diff > ul > .del" do
          expect(page).to have_content("25.0")
        end

        within ".diff > ul > .ins" do
          expect(page).to have_content("50.0")
        end
      end
    end
  end
end
