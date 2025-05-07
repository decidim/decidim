# frozen_string_literal: true

require "decidim/dev/test/rspec_support/tom_select"

shared_examples "manage results" do
  describe "admin form" do
    before { click_on "New result", match: :first }

    it_behaves_like "having a rich text editor", "new_result", "full"
  end

  it "displays the proposals picker" do
    expect(page).to have_content("Proposals")
  end

  context "when proposal linking is disabled" do
    before do
      allow(Decidim).to receive(:module_installed?).and_call_original

      # Reload the page with the updated settings
      visit current_path
    end

    it "does not display the proposal picker" do
      expect(page).to have_no_content "Choose proposals"
    end
  end

  context "when having existing proposals" do
    let!(:proposal_component) { create(:proposal_component, participatory_space:) }
    let!(:proposals) { create_list(:proposal, 5, component: proposal_component) }
    let(:attributes) { attributes_for(:result, component: current_component) }

    it "updates a result" do
      within "tr", text: translated(result.title) do
        click_on "Edit"
      end

      within ".edit_result" do
        fill_in_i18n(:result_title, "#result-title-tabs", **attributes[:title].except("machine_translations"))

        tom_select("#proposals_list", option_id: proposals.first(2).map(&:id))
      end
      within ".item__edit-sticky" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).to have_content(translated(attributes[:title]))
      end

      visit decidim_admin.root_path
      expect(page).to have_content("updated result")
      expect(page).to have_content(translated(attributes[:title]))
    end

    it "creates a new result", :slow do
      click_on "New result", match: :first

      within ".new_result" do
        fill_in_i18n(:result_title, "#result-title-tabs", **attributes[:title].except("machine_translations"))
        fill_in_i18n_editor(:result_description, "#result-description-tabs", **attributes[:description].except("machine_translations"))

        tom_select("#proposals_list", option_id: proposals.first(2).map(&:id))

        select decidim_sanitize_translated(taxonomy.name), from: "taxonomies-#{taxonomy_filter.id}"
      end
      within ".item__edit-sticky" do
        find("*[type=submit]").click
      end
      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).to have_content(translated(attributes[:title]))
        expect(page).to have_content(decidim_sanitize_translated(taxonomy.name))
      end

      visit decidim_admin.root_path
      expect(page).to have_content("created result")
      expect(page).to have_content(attributes[:title]["en"])

      visit decidim.last_activities_path
      expect(page).to have_content("New result: #{translated(attributes[:title])}")

      within "#filters" do
        find("a", class: "filter", text: "Result", match: :first).click
      end
      expect(page).to have_content("New result: #{translated(attributes[:title])}")
    end
  end

  it "allows the user to preview the result" do
    within "tr", text: translated(result.title) do
      klass = "action-icon--preview"
      href = resource_locator(result).path
      target = "blank"

      expect(page).to have_xpath(
        "//a[contains(@class,'#{klass}')][@href='#{href}'][@target='#{target}']"
      )
    end
  end

  describe "deleting a result" do
    let!(:result2) { create(:result, component: current_component) }

    before do
      visit current_path
    end

    it "deletes a result" do
      within "tr", text: translated(result2.title) do
        accept_confirm { click_on "Soft delete" }
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).to have_no_content(translated(result2.title))
      end
    end
  end
end
