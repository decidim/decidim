# frozen_string_literal: true

require "spec_helper"

describe "Admin creates proposals" do
  let(:manifest_name) { "proposals" }
  let(:creation_enabled?) { true }
  let(:new_title) { "This is my proposal new title" }
  let(:new_body) { "This is my proposal new body" }

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
    fill_in :proposal_attachment_title, with: "FOO BAR"
    dynamically_attach_file(:proposal_attachment_file, Decidim::Dev.asset("city.jpeg"))
    click_on("Create")
    find("a.action-icon--edit-proposal").click

    expect(page).to have_content("city.jpeg")
    expect(page).to have_content("FOO BAR")
  end
end
