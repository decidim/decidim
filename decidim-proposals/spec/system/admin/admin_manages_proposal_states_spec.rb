# frozen_string_literal: true

require "spec_helper"

describe "Admin manages proposals states" do
  include_context "when managing a component as an admin" do
    let!(:component) { create(:proposal_component, participatory_space:) }
  end

  describe "visiting the component admin page" do
    it "lists the proposal states button" do
      expect(page).to have_content("Statuses")
    end
  end

  describe "listing proposal states page" do
    before do
      click_on "Statuses"
    end

    it "lists the default proposal states" do
      expect(page).to have_content("Status")
      expect(page).to have_link("New status")

      within "table" do
        expect(page).to have_content("Status")
        expect(page).to have_content("Accepted")
        expect(page).to have_content("Rejected")
        expect(page).to have_content("Evaluating")
      end
    end
  end

  describe "creating a proposal state" do
    let(:attributes) { attributes_for(:proposal_state) }

    before do
      click_on "Statuses"
      click_on "New status"
    end

    it "creates a new proposal state" do
      expect(Decidim::Proposals::ProposalState.find_by(token: "custom")).to be_nil
      within ".new_proposal_state" do
        fill_in_i18n(:proposal_state_title, "#proposal_state-title-tabs", **attributes[:title].except("machine_translations"))
        fill_in_i18n(:proposal_state_announcement_title, "#proposal_state-announcement_title-tabs", **attributes[:announcement_title].except("machine_translations"))

        within ".proposal-status__color" do
          find_by_id("proposal_state_text_color_9a6700").click
        end

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).to have_css(".label", style: "background-color: #FFFCE5; color: #9A6700; border-color: #9A6700;")
        expect(page).to have_content(translated(attributes[:title]))
      end

      state = Decidim::Proposals::ProposalState.find_by(token: "script_alert_proposal_state_title_script_not_answered")
      expect(state).to be_present
      expect(translated(state.title)).to eq(translated(attributes[:title]))
      expect(translated(state.announcement_title)).to eq(translated(attributes[:announcement_title]))
      expect(state.css_style).to eq("background-color: #FFFCE5; color: #9A6700; border-color: #9A6700;")

      visit decidim_admin.root_path
      expect(page).to have_content("created #{translated(attributes[:title])} in")
    end

    it "updates the label and announcement previews" do
      expect(Decidim::Proposals::ProposalState.find_by(token: "custom")).to be_nil
      within ".new_proposal_state" do
        fill_in_i18n(
          :proposal_state_title,
          "#proposal_state-title-tabs",
          en: "Custom state",
          es: "Estado personalizado",
          ca: "Estat personalitzat"
        )

        fill_in_i18n(
          :proposal_state_announcement_title,
          "#proposal_state-announcement_title-tabs",
          en: "A longer announcement",
          es: "Anuncio más largo",
          ca: "Anunci més llarg"
        )

        within ".proposal-status__color" do
          find_by_id("proposal_state_text_color_9a6700").click
        end

        expect(page).to have_css("[data-label-preview]", style: "background-color: rgb(255, 252, 229); color: rgb(154, 103, 0);")
        within "[data-label-preview]" do
          expect(page).to have_content("Estat personalitzat")
        end

        expect(page).to have_css("[data-announcement-preview]", style: "background-color: rgb(255, 252, 229); color: rgb(154, 103, 0); border-color: #9A6700/var(--tw-border-opacity);")
        within "[data-announcement-preview]" do
          expect(page).to have_content("Anunci més llarg")
        end
      end
    end
  end

  describe "editing a proposal state" do
    let(:state_params) do
      {
        title: { "en" => "Editable state" },
        announcement_title: { "en" => "Editable announcement title" },
        token: "editable_state",
        bg_color: "#EBF9FF",
        text_color: "#0851A6"
      }
    end
    let!(:proposal_state) { create(:proposal_state, component: current_component, **state_params) }
    let(:attributes) { attributes_for(:proposal_state) }

    before do
      click_on "Statuses"
    end

    it "displays the proposal state" do
      expect(page).to have_content("Editable state")
    end

    it "updates a proposal state" do
      within "tr", text: translated(proposal_state.title) do
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

      within "table" do
        expect(page).to have_css(".label", style: "background-color: #FFFCE5; color: #9A6700; border-color: #9A6700;")
        expect(page).to have_content(translated(attributes[:title]))
      end

      state = Decidim::Proposals::ProposalState.find_by(token: "editable_state")

      expect(translated(state.title)).to eq(translated(attributes[:title]))
      expect(translated(state.announcement_title)).to eq(translated(attributes[:announcement_title]))
      expect(state.css_style).to eq("background-color: #FFFCE5; color: #9A6700; border-color: #9A6700;")

      visit decidim_admin.root_path
      expect(page).to have_content("updated #{translated(attributes[:title])} in")
    end

    it "updates the label and announcement previews" do
      within "tr", text: translated(proposal_state.title) do
        click_on "Edit"
      end

      within ".edit_proposal_state" do
        fill_in_i18n(:proposal_state_title, "#proposal_state-title-tabs", **attributes[:title].except("machine_translations"))
        fill_in_i18n(:proposal_state_announcement_title, "#proposal_state-announcement_title-tabs", **attributes[:announcement_title].except("machine_translations"))

        within ".proposal-status__color" do
          find_by_id("proposal_state_text_color_9a6700").click
        end

        expect(page).to have_css("[data-label-preview]", style: "background-color: rgb(255, 252, 229); color: rgb(154, 103, 0);")
        within "[data-label-preview]" do
          expect(page).to have_content(translated(attributes[:title]))
        end

        expect(page).to have_css("[data-announcement-preview]", style: "background-color: rgb(255, 252, 229); color: rgb(154, 103, 0); border-color: #9A6700/var(--tw-border-opacity);")
        within "[data-announcement-preview]" do
          # text_copy.js implements a change event that updates the label. The fill_in_i18n is "changing" the fields, and the "ca" locale is the last one that one that is being changed
          expect(page).to have_content(translated(attributes[:announcement_title], locale: "ca"))
        end
        find("*[type=submit]").click
      end
      expect(page).to have_admin_callout("successfully")

      visit decidim_admin.root_path
      expect(page).to have_content("updated #{translated(attributes[:title])} in")
    end
  end

  describe "deleting a proposal state" do
    let(:state_params) do
      {
        title: { "en" => "Editable state" },
        announcement_title: { "en" => "Editable announcement title" },
        token: "editable",
        bg_color: "#EBF9FF",
        text_color: "#0851A6"
      }
    end
    let!(:state) { create(:proposal_state, component: current_component, **state_params) }

    before do
      click_on "Statuses"
    end

    it "deletes the proposal state" do
      within "tr", text: translated(state.title) do
        accept_confirm { click_on "Delete" }
      end
      expect(page).to have_admin_callout("successfully")

      state = Decidim::Proposals::ProposalState.find_by(token: "editable")

      expect(state).to be_nil
    end

    it "does not delete the proposal state if there are proposals attached" do
      proposal = create(:proposal, component: current_component, state: state.token)

      visit current_path
      expect(state.reload.proposals).to include(proposal)
      expect(state.proposals_count).to eq(1)
      within "tr", text: translated(state.title) do
        expect(page).to have_no_link("Delete")
      end
    end
  end
end
