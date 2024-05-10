# frozen_string_literal: true

require "spec_helper"

describe "Admin views admin logs" do
  let(:manifest_name) { "accountability" }

  include_context "when managing a component as an admin"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit_component_admin
  end

  describe "timeline entry" do
    let!(:result) { create(:result, component: current_component) }
    let(:attributes) { attributes_for(:timeline_entry, result:) }
    let!(:timeline_entries) { create(:timeline_entry, result:) }

    before do
      visit_component_admin
      within "tr", text: translated(result.title) do
        click_on "Project evolution"
      end
    end

    it "updates a timeline entry", versioning: true do
      click_on "Edit", match: :first

      within ".edit_timeline_entry" do
        fill_in :timeline_entry_entry_date_date, with: Date.current.strftime("%d/%m/%Y")
        fill_in_i18n(:timeline_entry_title, "#timeline_entry-title-tabs", **attributes[:title].except("machine_translations"))
        fill_in_i18n_editor(:timeline_entry_description, "#timeline_entry-description-tabs", **attributes[:description].except("machine_translations"))

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      visit decidim_admin.root_path
      expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
    end

    it "creates a timeline entry", versioning: true do
      click_on "New timeline entry", match: :first

      within ".new_timeline_entry" do
        fill_in :timeline_entry_entry_date_date, with: Date.current.strftime("%d/%m/%Y")
        fill_in_i18n(:timeline_entry_title, "#timeline_entry-title-tabs", **attributes[:title].except("machine_translations"))
        fill_in_i18n_editor(:timeline_entry_description, "#timeline_entry-description-tabs", **attributes[:description].except("machine_translations"))

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      visit decidim_admin.root_path
      expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
    end
  end

  describe "result" do
    let(:attributes) { attributes_for(:result, component: current_component) }
    let!(:result) { create(:result, component: current_component) }

    let!(:proposal_component) { create(:proposal_component, participatory_space:) }
    let!(:proposals) { create_list(:proposal, 5, component: proposal_component) }

    it "updates a result", versioning: true do
      visit_component_admin
      within "tr", text: translated(result.title) do
        click_on "Edit"
      end

      within ".edit_result" do
        fill_in_i18n(:result_title, "#result-title-tabs", **attributes[:title].except("machine_translations"))
        tom_select("#proposals_list", option_id: proposals.first(2).map(&:id))

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      visit decidim_admin.root_path
      expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
    end

    it "creates a new result", versioning: true do
      click_on "New result", match: :first

      within ".new_result" do
        fill_in_i18n(:result_title, "#result-title-tabs", **attributes[:title].except("machine_translations"))
        fill_in_i18n_editor(:result_description, "#result-description-tabs", **attributes[:description].except("machine_translations"))
        tom_select("#proposals_list", option_id: proposals.first(2).map(&:id))

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      visit decidim_admin.root_path
      expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
    end
  end

  describe "statuses" do
    let(:attributes) { attributes_for(:status) }
    let!(:status) { create(:status, component: current_component) }

    before do
      click_on "Statuses"
    end

    it "updates a status", versioning: true do
      within "tr", text: status.key do
        click_on "Edit"
      end

      within ".edit_status" do
        fill_in_i18n(:status_name, "#status-name-tabs", **attributes[:name].except("machine_translations"))

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      visit decidim_admin.root_path
      expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
    end

    it "creates a new status", versioning: true do
      click_on "New status"

      within ".new_status" do
        fill_in :status_key, with: "status_key_1"

        fill_in_i18n(:status_name, "#status-name-tabs", **attributes[:name].except("machine_translations"))
        fill_in_i18n(:status_description, "#status-description-tabs", **attributes[:description].except("machine_translations"))

        fill_in :status_progress, with: 75

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      visit decidim_admin.root_path
      expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
    end
  end
end
