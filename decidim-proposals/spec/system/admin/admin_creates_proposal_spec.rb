# frozen_string_literal: true

require "spec_helper"

describe "Admin creates proposals" do
  let(:manifest_name) { "proposals" }
  let(:creation_enabled?) { true }
  let(:new_title) { "This is my proposal new title" }
  let(:new_body) { "This is my proposal new body" }
  let(:image_filename) { "city2.jpeg" }
  let(:image_path) { Decidim::Dev.asset(image_filename) }
  let(:document_filename) { "Exampledocument.pdf" }
  let(:document_path) { Decidim::Dev.asset(document_filename) }

  include_context "when managing a component as an admin" do
    let!(:component) { create(:proposal_component, participatory_space:) }
  end

  before do
    component.update!(
      settings: { official_proposals_enabled: true, attachments_allowed: true, creation_enabled: true },
      step_settings: {
        component.participatory_space.active_step.id => {
          creation_enabled: creation_enabled?
        }
      }
    )
  end

  it "can attach a file" do
    visit_component_admin
    click_on("New proposal")

    fill_in_i18n :proposal_title, "#proposal-title-tabs", en: new_title
    fill_in_i18n_editor :proposal_body, "#proposal-body-tabs", en: new_body
    dynamically_attach_file(:proposal_documents, image_path)
    dynamically_attach_file(:proposal_documents, document_path)

    click_on("Create")
    within "tr", text: translated_attribute(new_title) do
      find("button[data-component='dropdown']").click
      click_on "Edit proposal"
    end

    expect(page).to have_content(image_filename)
    expect(page).to have_content(document_filename)
  end

  it "displays the correct version link", versioning: true do
    visit_component_admin
    click_on("New proposal")

    fill_in_i18n :proposal_title, "#proposal-title-tabs", en: new_title
    fill_in_i18n_editor :proposal_body, "#proposal-body-tabs", en: new_body
    click_on("Create")
    expect(page).to have_admin_callout("successfully")

    path = resource_locator(Decidim::Proposals::Proposal.last).path

    visit path

    expect(page).to have_link("see other versions", href: "#{path}/versions/1")
  end

  describe "validating the form" do
    before do
      visit_component_admin
      click_on("New proposal")
    end

    context "when focus shifts to body" do
      it "displays error when title is empty" do
        fill_in_i18n :proposal_title, "#proposal-title-tabs", en: " "
        find_by_id("proposal-body-tabs").click

        expect(page).to have_css(".form-error.is-visible", text: "There is an error in this field.")
      end

      it "displays error when title is invalid" do
        fill_in_i18n :proposal_title, "#proposal-title-tabs", en: "invalid-title"
        find_by_id("proposal-body-tabs").click

        expect(page).to have_css(".form-error.is-visible", text: "There is an error in this field")
      end
    end

    context "when focus remains on title" do
      it "does not display error when title is empty" do
        fill_in_i18n :proposal_title, "#proposal-title-tabs", en: " "
        find_by_id("proposal-title-tabs").click

        expect(page).to have_no_css(".form-error.is-visible", text: "There is an error in this field.")
      end

      it "does not display error when title is invalid" do
        fill_in_i18n :proposal_title, "#proposal-title-tabs", en: "invalid-title"
        find_by_id("proposal-title-tabs").click

        expect(page).to have_no_css(".form-error.is-visible", text: "There is an error in this field")
      end
    end
  end
end
