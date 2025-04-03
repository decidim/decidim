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

  it_behaves_like "create proposals"

  context "when is a process admin" do
    let(:user) do
      create(:process_admin,
             :confirmed,
             organization:,
             participatory_process:)
    end

    it_behaves_like "create proposals"
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
