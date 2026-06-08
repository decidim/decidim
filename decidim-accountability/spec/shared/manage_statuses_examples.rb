# frozen_string_literal: true

RSpec.shared_examples "manage statuses" do
  let(:attributes) { attributes_for(:status) }

  it "updates a status" do
    within "tr", text: status.key do
      find("button[data-controller='dropdown']").click
      click_on "Edit"
    end

    within ".edit_status" do
      fill_in_i18n(
        :status_name,
        "#status-name-tabs",
        **attributes[:name].except("machine_translations")
      )

      find("*[type=submit]").click
    end

    expect(page).to have_callout("Status successfully updated.")

    within "table" do
      expect(page).to have_text(translated(attributes[:name]))
    end

    visit decidim_admin.root_path
    expect(page).to have_text("updated the #{translated(attributes[:name])} status")
  end

  it "creates a new status" do
    click_on "New status"

    within ".new_status" do
      fill_in :status_key, with: "status_key_1"

      fill_in_i18n(:status_name, "#status-name-tabs", **attributes[:name].except("machine_translations"))
      fill_in_i18n(:status_description, "#status-description-tabs", **attributes[:description].except("machine_translations"))

      fill_in :status_progress, with: 75

      find("*[type=submit]").click
    end

    expect(page).to have_callout("Status successfully created.")

    within "table" do
      expect(page).to have_text("status_key_1")
      expect(page).to have_text(translated(attributes[:name]))
    end

    visit decidim_admin.root_path
    expect(page).to have_text("created the #{translated(attributes[:name])} status")
  end

  describe "deleting a result" do
    let!(:status2) { create(:status, component: current_component) }

    before do
      visit current_path
    end

    it "deletes a status" do
      within "tr", text: status2.key do
        find("button[data-controller='dropdown']").click
        accept_confirm { click_on "Delete" }
      end

      expect(page).to have_callout("Status successfully deleted.")

      within "table" do
        expect(page).to have_no_text(status2.key)
      end
    end
  end

  describe "sorts statuses" do
    let(:statuses) do
      [
        create(:status, key: "status_106", progress: 0, component: current_component),
        create(:status, key: "status_110", progress: 30, component: current_component),
        create(:status, key: "status_105", progress: 60, component: current_component),
        create(:status, key: "status_104", progress: 90, component: current_component),
        create(:status, key: "status_120", progress: 100, component: current_component)
      ]
    end

    before do
      # Replace the statuses with the new ones defined above so that we can have
      # an expected order of the rows.
      Decidim::Accountability::Status.where(component: current_component).destroy_all
      statuses

      expect(page).to have_text("Statuses")
      visit current_path
      expect(page).to have_text("status_106")
    end

    it "sorts by progress by default" do
      expect(all("tr")[1].text).to include("status_106")
      expect(all("tr")[2].text).to include("status_110")
      expect(all("tr")[3].text).to include("status_105")
      expect(all("tr")[4].text).to include("status_104")
      expect(all("tr")[5].text).to include("status_120")
    end

    it "can sort based on key" do
      within(all("tr").first) { click_on "Key" }

      expect(all("tr")[1].text).to include("status_104")
      expect(all("tr")[2].text).to include("status_105")
      expect(all("tr")[3].text).to include("status_106")
      expect(all("tr")[4].text).to include("status_110")
      expect(all("tr")[5].text).to include("status_120")
    end

    it "can sort based on name" do
      within(all("tr").first) { click_on "Name" }

      expected_order = statuses.sort do |s1, s2|
        s1.name["en"] <=> s2.name["en"]
      end

      expected_order.each_with_index do |status, idx|
        expect(all("tr")[1 + idx].text).to include(status.key)
      end
    end
  end
end
