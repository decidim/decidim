# frozen_string_literal: true

require "spec_helper"

describe "Admin manages proposals statuses" do
  include_context "when managing a component as an admin" do
    let!(:component) { create(:proposal_component, participatory_space:) }
  end

  describe "visiting the component admin page" do
    it "lists the proposal statuses button" do
      expect(page).to have_text("Statuses")
    end
  end

  describe "listing proposal statuses page" do
    before do
      click_on "Statuses"
    end

    it "lists the default proposal statuses" do
      expect(page).to have_text("Status")
      expect(page).to have_link("New status")

      within "table" do
        expect(page).to have_text("Status")
        expect(page).to have_text("Accepted")
        expect(page).to have_text("Rejected")
        expect(page).to have_text("Evaluating")
      end
    end
  end

  describe "creating a proposal status" do
    let(:attributes) { attributes_for(:proposal_status) }

    before do
      click_on "Statuses"
      click_on "New status"
    end

    it "creates a new proposal status" do
      expect(Decidim::Proposals::ProposalStatus.find_by(token: "custom")).to be_nil
      within ".new_proposal_status" do
        fill_in_i18n(:proposal_status_title, "#proposal_status-title-tabs", **attributes[:title].except("machine_translations"))
        fill_in_i18n(:proposal_status_announcement_title, "#proposal_status-announcement_title-tabs", **attributes[:announcement_title].except("machine_translations"))

        within ".proposal-status__color" do
          find_by_id("proposal_status_text_color_9a6700").click
        end

        find("*[type=submit]").click
      end

      expect(page).to have_callout("Status created successfully")

      within "table" do
        expect(page).to have_css(".label", style: "background-color: #FFFCE5; color: #9A6700; border-color: #9A6700;")
        expect(page).to have_text(translated(attributes[:title]))
      end

      status = Decidim::Proposals::ProposalStatus.find_by(token: "script_alert_proposal_status_title_script_not_answered")
      expect(status).to be_present
      expect(translated(status.title)).to eq(translated(attributes[:title]))
      expect(translated(status.announcement_title)).to eq(translated(attributes[:announcement_title]))
      expect(status.css_style).to eq("background-color: #FFFCE5; color: #9A6700; border-color: #9A6700;")

      visit decidim_admin.root_path
      expect(page).to have_text("created #{translated(attributes[:title])} in")
    end

    it "updates the label and announcement previews" do
      expect(Decidim::Proposals::ProposalStatus.find_by(token: "custom")).to be_nil
      within ".new_proposal_status" do
        fill_in_i18n(
          :proposal_status_title,
          "#proposal_status-title-tabs",
          en: "Custom status",
          es: "Estado personalizado",
          ca: "Estat personalitzat"
        )

        fill_in_i18n(
          :proposal_status_announcement_title,
          "#proposal_status-announcement_title-tabs",
          en: "A longer announcement",
          es: "Anuncio más largo",
          ca: "Anunci més llarg"
        )

        within ".proposal-status__color" do
          find_by_id("proposal_status_text_color_9a6700").click
        end

        expect(page).to have_css("[data-label-preview]", style: "background-color: rgb(255, 252, 229); color: rgb(154, 103, 0);")
        within "[data-label-preview]" do
          expect(page).to have_text("Estat personalitzat")
        end

        expect(page).to have_css("[data-announcement-preview]", style: "background-color: rgb(255, 252, 229); color: rgb(154, 103, 0); border-color: #9A6700/var(--tw-border-opacity);")
        within "[data-announcement-preview]" do
          expect(page).to have_text("Anunci més llarg")
        end
      end
    end
  end

  describe "editing a proposal status" do
    let(:status_params) do
      {
        title: { "en" => "Editable status" },
        announcement_title: { "en" => "Editable announcement title" },
        token: "editable_status",
        bg_color: "#EBF9FF",
        text_color: "#0851A6"
      }
    end
    let!(:proposal_status) { create(:proposal_status, component: current_component, **status_params) }
    let(:attributes) { attributes_for(:proposal_status) }

    before do
      click_on "Statuses"
    end

    it "displays the proposal status" do
      expect(page).to have_text("Editable status")
    end

    it "updates a proposal status" do
      within "tr", text: translated(proposal_status.title) do
        find("button[data-controller='dropdown']").click
        click_on "Edit"
      end

      within ".edit_proposal_status" do
        fill_in_i18n(:proposal_status_title, "#proposal_status-title-tabs", **attributes[:title].except("machine_translations"))
        fill_in_i18n(:proposal_status_announcement_title, "#proposal_status-announcement_title-tabs", **attributes[:announcement_title].except("machine_translations"))

        within ".proposal-status__color" do
          find_by_id("proposal_status_text_color_9a6700").click
        end

        find("*[type=submit]").click
      end
      expect(page).to have_callout("Status updated successfully")

      within "table" do
        expect(page).to have_css(".label", style: "background-color: #FFFCE5; color: #9A6700; border-color: #9A6700;")
        expect(page).to have_text(translated(attributes[:title]))
      end

      status = Decidim::Proposals::ProposalStatus.find_by(token: "editable_status")

      expect(translated(status.title)).to eq(translated(attributes[:title]))
      expect(translated(status.announcement_title)).to eq(translated(attributes[:announcement_title]))
      expect(status.css_style).to eq("background-color: #FFFCE5; color: #9A6700; border-color: #9A6700;")

      visit decidim_admin.root_path
      expect(page).to have_text("updated #{translated(attributes[:title])} in")
    end

    it "updates the label and announcement previews" do
      within "tr", text: translated(proposal_status.title) do
        find("button[data-controller='dropdown']").click
        click_on "Edit"
      end

      within ".edit_proposal_status" do
        fill_in_i18n(:proposal_status_title, "#proposal_status-title-tabs", **attributes[:title].except("machine_translations"))
        fill_in_i18n(:proposal_status_announcement_title, "#proposal_status-announcement_title-tabs", **attributes[:announcement_title].except("machine_translations"))

        within ".proposal-status__color" do
          find_by_id("proposal_status_text_color_9a6700").click
        end

        expect(page).to have_css("[data-label-preview]", style: "background-color: rgb(255, 252, 229); color: rgb(154, 103, 0);")
        within "[data-label-preview]" do
          expect(page).to have_text(translated(attributes[:title]))
        end

        expect(page).to have_css("[data-announcement-preview]", style: "background-color: rgb(255, 252, 229); color: rgb(154, 103, 0); border-color: #9A6700/var(--tw-border-opacity);")
        within "[data-announcement-preview]" do
          # text_copy.js implements a change event that updates the label. The fill_in_i18n is "changing" the fields, and the "ca" locale is the last one that one that is being changed
          expect(page).to have_text(translated(attributes[:announcement_title], locale: "ca"))
        end
        find("*[type=submit]").click
      end
      expect(page).to have_callout("Status updated successfully")

      visit decidim_admin.root_path
      expect(page).to have_text("updated #{translated(attributes[:title])} in")
    end
  end

  describe "deleting a proposal status" do
    let(:status_params) do
      {
        title: { "en" => "Editable status" },
        announcement_title: { "en" => "Editable announcement title" },
        token: "editable",
        bg_color: "#EBF9FF",
        text_color: "#0851A6"
      }
    end
    let!(:status) { create(:proposal_status, component: current_component, **status_params) }

    before do
      click_on "Statuses"
    end

    it "deletes the proposal status" do
      within "tr", text: translated(status.title) do
        find("button[data-controller='dropdown']").click
        accept_confirm { click_on "Delete" }
      end
      expect(page).to have_callout("Status deleted successfully")

      status = Decidim::Proposals::ProposalStatus.find_by(token: "editable")

      expect(status).to be_nil
    end

    it "does not delete the proposal status if there are proposals attached" do
      proposal = create(:proposal, component: current_component, status: status.token)

      visit current_path
      expect(status.reload.proposals).to include(proposal)
      expect(status.proposals_count).to eq(1)
      within "tr", text: translated(status.title) do
        find("button[data-controller='dropdown']").click
        expect(page).to have_no_link("Delete")
        expect(page).to have_css(".dropdown__button-disabled span", text: "Delete status")
        expect(page).to have_css(".dropdown__button-disabled svg")
      end
    end
  end
end
