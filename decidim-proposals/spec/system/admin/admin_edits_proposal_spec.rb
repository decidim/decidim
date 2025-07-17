# frozen_string_literal: true

require "spec_helper"

describe "Admin edits proposals" do
  let(:manifest_name) { "proposals" }
  let(:organization) { participatory_process.organization }
  let!(:user) { create(:user, :admin, :confirmed, organization:) }
  let!(:proposal) { create(:proposal, :official, component:) }
  let(:creation_enabled?) { true }
  let(:image_filename) { "city.jpeg" }
  let(:image_path) { Decidim::Dev.asset(image_filename) }

  include_context "when managing a component as an admin"

  before do
    component.update!(
      step_settings: {
        component.participatory_space.active_step.id => {
          creation_enabled: creation_enabled?
        }
      }
    )
  end

  describe "editing an official proposal" do
    let(:attributes) { attributes_for(:proposal, component: current_component) }

    it "can be updated" do
      visit_component_admin

      within "tr[data-id='#{proposal.id}']" do
        find("button[data-component='dropdown']").click
        click_on "Edit proposal"
      end
      expect(page).to have_content "Update proposal"

      fill_in_i18n :proposal_title, "#proposal-title-tabs", **attributes[:title].except("machine_translations")
      fill_in_i18n_editor :proposal_body, "#proposal-body-tabs", **attributes[:body].except("machine_translations")
      click_on "Update"

      within "tr[data-id='#{proposal.id}']" do
        find("button[data-component='dropdown']").click
        preview_window = window_opened_by { click_on "Preview" }

        within_window preview_window do
          expect(page).to have_content(translated(attributes[:title]))
          expect(page).to have_content(strip_tags(translated(attributes[:body])).strip)
        end
      end

      expect(page).to have_admin_callout("successfully")

      visit decidim_admin.root_path
      expect(page).to have_content("updated the #{translated(attributes[:title])} official proposal")
    end

    context "when the proposal has some votes" do
      before do
        create(:proposal_vote, proposal:)
      end

      it "does not let the user edit it" do
        visit_component_admin

        expect(page).to have_content(translated(proposal.title))
        within "tr", text: translated_attribute(proposal.title) do
          find("button[data-component='dropdown']").click
          expect(page).to have_css(".dropdown__button-disabled span", text: "Edit proposal")
        end
        visit current_path + "proposals/#{proposal.id}/edit"

        expect(page).to have_content("not authorized")
      end
    end

    context "when the proposal has attachment" do
      let!(:component) do
        create(:proposal_component,
               :with_creation_enabled,
               :with_attachments_allowed,
               manifest:,
               participatory_space: participatory_process)
      end

      let!(:proposal) do
        create(:proposal,
               :official,
               component:,
               title: "Proposal with attachments",
               body: "This is my proposal and I want to upload attachments.")
      end

      let!(:document) { create(:attachment, :with_pdf, attached_to: proposal) }

      it "can be remove attachment" do
        visit_component_admin
        within "tr", text: translated_attribute(proposal.title) do
          find("button[data-component='dropdown']").click
          click_on "Edit proposal"
        end
        within ".item__edit-form" do
          click_on "Update"
        end

        expect(page).to have_content("Proposal successfully updated.")

        visit_component_admin
        within "tr", text: translated_attribute(proposal.title) do
          find("button[data-component='dropdown']").click
          click_on "Edit proposal"
        end
        expect(page).to have_no_content("Current file")
      end

      it "can attach a file" do
        visit_component_admin
        within "tr", text: translated_attribute(proposal.title) do
          find("button[data-component='dropdown']").click
          click_on "Edit proposal"
        end
        dynamically_attach_file(:proposal_documents, image_path)

        click_on("Edit attachments")
        within "li[data-filename='#{image_filename}']" do
          click_on("Remove")
        end
        click_on("Save")

        click_on("Update")

        within "tr", text: translated_attribute(proposal.title) do
          find("button[data-component='dropdown']").click
          click_on "Edit proposal"
        end

        expect(page).to have_no_content("city.jpeg")
      end
    end
  end

  describe "editing a non-official proposal" do
    let!(:proposal) { create(:proposal, users: [user], component:) }

    it "renders an error" do
      visit_component_admin

      expect(page).to have_content(translated(proposal.title))

      within "tr", text: translated_attribute(proposal.title) do
        find("button[data-component='dropdown']").click
        expect(page).to have_css(".dropdown__button-disabled span", text: "Edit proposal")
      end

      visit current_path + "proposals/#{proposal.id}/edit"

      expect(page).to have_content("not authorized")
    end
  end
end
