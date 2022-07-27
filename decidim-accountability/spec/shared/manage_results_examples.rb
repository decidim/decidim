# frozen_string_literal: true

shared_examples "manage results" do
  include_context "when managing an accountability component as an admin"

  describe "admin form" do
    before { click_on "New Result", match: :first }

    it_behaves_like "having a rich text editor", "new_result", "full"

    it "displays the proposals picker" do
      expect(page).to have_content("Choose proposals")
    end

    context "when proposal linking is disabled" do
      before do
        allow(Decidim::Accountability).to receive(:enable_proposal_linking).and_return(false)

        # Reload the page with the updated settings
        visit current_path
      end

      it "does not display the proposal picker" do
        expect(page).not_to have_content "Choose proposals"
      end
    end
  end

  context "when having existing proposals" do
    let!(:proposal_component) { create(:proposal_component, participatory_space:) }
    let!(:proposals) { create_list :proposal, 5, component: proposal_component, skip_injection: true }

    it "updates a result" do
      within find("tr", text: translated(result.title)) do
        click_link "Edit"
      end

      within ".edit_result" do
        fill_in_i18n(
          :result_title,
          "#result-title-tabs",
          en: "My new title",
          es: "Mi nuevo título",
          ca: "El meu nou títol"
        )

        proposals_pick(select_data_picker(:result_proposals, multiple: true), proposals.last(2))

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).to have_content("My new title")
      end
    end

    it "creates a new result", :slow do
      click_link "New Result", match: :first

      within ".new_result" do
        fill_in_i18n(
          :result_title,
          "#result-title-tabs",
          en: "My result",
          es: "Mi result",
          ca: "El meu result"
        )
        fill_in_i18n_editor(
          :result_description,
          "#result-description-tabs",
          en: "A longer description",
          es: "Descripción más larga",
          ca: "Descripció més llarga"
        )

        proposals_pick(select_data_picker(:result_proposals, multiple: true), proposals.first(2))
        scope_pick(select_data_picker(:result_decidim_scope_id), scope)
        select translated(category.name), from: :result_decidim_category_id

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).to have_content("My result")
      end
    end
  end

  it "allows the user to preview the result" do
    within find("tr", text: translated(result.title)) do
      klass = "action-icon--preview"
      href = resource_locator(result).path
      target = "blank"

      expect(page).to have_selector(
        :xpath,
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
      within find("tr", text: translated(result2.title)) do
        accept_confirm { click_link "Delete" }
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).to have_no_content(translated(result2.title))
      end
    end
  end
end
