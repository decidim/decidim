# frozen_string_literal: true

require "spec_helper"

describe "Admin manages proposals states" do
  include_context "when managing a component as an admin" do
    let!(:component) { create(:proposal_component, participatory_space:) }
  end

  context "when visiting the component admin page" do
    it "lists the proposal states button" do
      expect(page).to have_content("States")
    end
  end

  context "when listing proposal states page" do
    before do
      click_link "States"
    end

    it "lists the default proposal states" do
      expect(page).to have_content("Proposal states")
      expect(page).to have_link("New proposal state")

      within "table" do
        expect(page).to have_content("Proposal state")
        expect(page).to have_content("Withdrawn")
        expect(page).to have_content("Accepted")
        expect(page).to have_content("Rejected")
        expect(page).to have_content("Evaluating")
        expect(page).to have_content("Not answered")
      end
    end
  end

  context "when creating a proposal state" do
    before do
      click_link "States"
      click_link "New proposal state"
    end

    it "creates a new proposal state" do
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
          :proposal_state_description,
          "#proposal_state-description-tabs",
          en: "A longer description",
          es: "Descripción más larga",
          ca: "Descripció més llarga"
        )

        fill_in_i18n(
          :proposal_state_announcement_title,
          "#proposal_state-announcement_title-tabs",
          en: "A longer anouncement",
          es: "Anuncio más larga",
          ca: "Anunci més llarga"
        )

        fill_in :proposal_state_token, with: "custom"
        fill_in :proposal_state_css_class, with: "csscustom"
        check "Default"
        check "Answerable"
        check "Notifiable"
        check "Gamified"

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).to have_css(".csscustom")
        expect(page).to have_content("Custom state")
      end

      state = Decidim::Proposals::ProposalState.find_by(token: "custom")
      expect(state).to be_present
      expect(state).to be_default
      expect(state).to be_answerable
      expect(state).to be_notifiable
      expect(state).to be_gamified
      expect(translated(state.title)).to eq("Custom state")
      expect(translated(state.description)).to eq("A longer description")
      expect(translated(state.announcement_title)).to eq("A longer anouncement")
      expect(state.css_class).to eq("csscustom")
    end
  end

  context "when editing a proposal state" do
    let(:state_params) do
      {
        title: { "en" => "Editable state" },
        description: { "en" => "Editable description" },
        announcement_title: { "en" => "Editable announcement title" },
        token: "editable",
        css_class: "csseditable",
        default: false,
        answerable: false,
        notifiable: false,
        gamified: false
      }
    end
    let!(:state) { create(:proposal_state, component: current_component, **state_params) }

    before do
      click_link "States"
    end

    it "displays the proposal state" do
      expect(page).to have_content("Editable state")
    end

    it "updates a proposal state" do
      within find("tr", text: translated(state.title)) do
        click_link "Edit"
      end

      within ".edit_proposal_state" do
        fill_in_i18n(
          :proposal_state_title,
          "#proposal_state-title-tabs",
          en: "Custom state",
          es: "Estado personalizado",
          ca: "Estat personalitzat"
        )

        fill_in_i18n(
          :proposal_state_description,
          "#proposal_state-description-tabs",
          en: "A longer description",
          es: "Descripción más larga",
          ca: "Descripció més llarga"
        )

        fill_in_i18n(
          :proposal_state_announcement_title,
          "#proposal_state-announcement_title-tabs",
          en: "A longer anouncement",
          es: "Anuncio más larga",
          ca: "Anunci més llarga"
        )

        fill_in :proposal_state_css_class, with: "csscustom"
        check "Default"
        check "Answerable"
        check "Notifiable"
        check "Gamified"

        find("*[type=submit]").click
      end

      within "table" do
        expect(page).to have_css(".csscustom")
        expect(page).to have_content("Custom state")
      end

      state = Decidim::Proposals::ProposalState.find_by(token: "editable")

      expect(state).to be_default
      expect(state).to be_answerable
      expect(state).to be_notifiable
      expect(state).to be_gamified
      expect(translated(state.title)).to eq("Custom state")
      expect(translated(state.description)).to eq("A longer description")
      expect(translated(state.announcement_title)).to eq("A longer anouncement")
      expect(state.css_class).to eq("csscustom")
    end
  end

  context "when deleting a proposal state" do
    let(:state_params) do
      {
        title: { "en" => "Editable state" },
        description: { "en" => "Editable description" },
        announcement_title: { "en" => "Editable announcement title" },
        token: "editable",
        css_class: "csseditable",
        default: false,
        answerable: false,
        notifiable: false,
        gamified: false,
        system: false
      }
    end
    let!(:state) { create(:proposal_state, component: current_component, **state_params) }

    before do
      click_link "States"
    end

    it "deletes the proposal state" do
      within find("tr", text: translated(state.title)) do
        accept_confirm { click_link "Delete" }
      end
      expect(page).to have_admin_callout("successfully")

      state = Decidim::Proposals::ProposalState.find_by(token: "editable")

      expect(state).to be_nil
    end

    it "does not delete the proposal state if it is a system state" do
      state.update(system: true)
      visit current_path

      within find("tr", text: translated(state.title)) do
        expect(page).not_to have_link("Delete")
      end
    end

    it "does not delete the proposal state if there are proposals attached" do
      proposal = create(:proposal, component: current_component, state: state.token)

      visit current_path
      expect(state.reload.proposals).to include(proposal)
      expect(state.proposals_count).to eq(1)
      within find("tr", text: translated(state.title)) do
        expect(page).not_to have_link("Delete")
      end
    end
  end
end
