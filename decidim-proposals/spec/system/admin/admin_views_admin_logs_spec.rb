# frozen_string_literal: true

require "spec_helper"

describe "Admin views admin logs" do
  let(:manifest_name) { "proposals" }
  let(:address) { "Some address" }
  let(:latitude) { 40.1234 }
  let(:longitude) { 2.1234 }

  include_context "when managing a component as an admin"

  describe "proposals" do
    before do
      stub_geocoding(address, [latitude, longitude])
      current_component.update!(
        step_settings: {
          current_component.participatory_space.active_step.id => {
            creation_enabled: true
          }
        }
      )
      visit_component_admin
    end

    let(:attributes) { attributes_for(:proposal, component: current_component) }

    it "creates a new proposal", versioning: true do
      click_on "New proposal"

      within ".new_proposal" do
        fill_in_i18n :proposal_title, "#proposal-title-tabs", **attributes[:title].except("machine_translations")
        fill_in_i18n_editor :proposal_body, "#proposal-body-tabs", **attributes[:body].except("machine_translations")
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      visit decidim_admin.root_path
      expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
    end
  end

  describe "proposal states" do
    let(:attributes) { attributes_for(:proposal_state) }
    let!(:state) { create(:proposal_state, component: current_component) }

    before do
      visit_component_admin
      click_on "Statuses"
    end

    it "creates a new proposal state", versioning: true do
      click_on "New status"

      within ".new_proposal_state" do
        fill_in_i18n(:proposal_state_title, "#proposal_state-title-tabs", **attributes[:title].except("machine_translations"))
        fill_in_i18n(:proposal_state_announcement_title, "#proposal_state-announcement_title-tabs", **attributes[:announcement_title].except("machine_translations"))

        within ".proposal-status__color" do
          find_by_id("proposal_state_text_color_9a6700").click
        end

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      visit decidim_admin.root_path
      expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
    end

    it "updates a proposal state", versioning: true do
      within "tr", text: translated(state.title) do
        click_on "Edit"
      end

      within ".edit_proposal_state" do
        fill_in_i18n(:proposal_state_title, "#proposal_state-title-tabs", **attributes[:title].except("machine_translations"))
        fill_in_i18n(:proposal_state_announcement_title, "#proposal_state-announcement_title-tabs", **attributes[:announcement_title].except("machine_translations"))

        within ".proposal-status__color" do
          find_by_id("proposal_state_text_color_9a6700").click
        end

        find("*[type=submit]").click
      end
      expect(page).to have_admin_callout("successfully")
      visit decidim_admin.root_path
      expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
    end
  end

  describe "proposal notes" do
    let(:attributes) { attributes_for(:proposal_note) }
    let!(:proposal) { create(:proposal, component: current_component) }

    it "creates a proposal note", versioning: true do
      visit current_path
      within "tr", text: translated(proposal.title) do
        click_on "Answer proposal"
      end
      click_on "Private notes"

      within ".new_proposal_note" do
        fill_in :proposal_note_body, with: attributes[:body]

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
      visit decidim_admin.root_path
      expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
    end
  end

  describe "valuators" do
    let!(:proposal) { create(:proposal, component: current_component) }
    let!(:valuator) { create(:user, organization:) }
    let!(:valuator_role) { create(:participatory_process_user_role, role: :valuator, user: valuator, participatory_process:) }

    before do
      visit current_path

      within "tr", text: translated(proposal.title) do
        page.first(".js-proposal-list-check").set(true)
      end

      click_on "Actions"
      click_on "Assign to valuator"
      within "#js-form-assign-proposals-to-valuator" do
        select valuator.name, from: :valuator_role_id
        click_on(id: "js-submit-assign-proposals-to-valuator")
      end
    end

    it "displays the log", versioning: true do
      visit decidim_admin.root_path
      expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
    end
  end
end
