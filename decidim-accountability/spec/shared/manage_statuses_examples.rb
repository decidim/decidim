# frozen_string_literal: true

RSpec.shared_examples "manage statuses" do
  let(:attributes) { attributes_for(:status) }

  it "updates a status" do
    within find("tr", text: status.key) do
      click_link "Edit"
    end

    within ".edit_status" do
      fill_in_i18n(
        :status_name,
        "#status-name-tabs",
        **attributes[:name].except("machine_translations")
      )

      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")

    within "table" do
      expect(page).to have_content(translated(attributes[:name]))
    end

    visit decidim_admin.root_path
    expect(page).to have_content("updated the #{translated(attributes[:name])} status")
  end

  it "creates a new status" do
    click_link "New status"

    within ".new_status" do
      fill_in :status_key, with: "status_key_1"

      fill_in_i18n(:status_name, "#status-name-tabs", **attributes[:name].except("machine_translations"))
      fill_in_i18n(:status_description, "#status-description-tabs", **attributes[:description].except("machine_translations"))

      fill_in :status_progress, with: 75

      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")

    within "table" do
      expect(page).to have_content("status_key_1")
      expect(page).to have_content(translated(attributes[:name]))
    end

    visit decidim_admin.root_path
    expect(page).to have_content("created the #{translated(attributes[:name])} status")
  end

  describe "deleting a result" do
    let!(:status2) { create(:status, component: current_component) }

    before do
      visit current_path
    end

    it "deletes a status" do
      within find("tr", text: status2.key) do
        accept_confirm { click_link "Delete" }
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).not_to have_content(status2.key)
      end
    end
  end
end
