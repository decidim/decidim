# frozen_string_literal: true

require "spec_helper"

describe "Admin creates proposals", type: :system do
  let(:manifest_name) { "proposals" }
  let(:creation_enabled?) { true }
  let!(:component) do
    create(:proposal_component,
           :with_creation_enabled,
           :with_attachments_allowed,
           manifest:,
           participatory_space: participatory_process)
  end
  let(:new_title) { "This is my proposal new title" }
  let(:new_body) { "This is my proposal new body" }

  include_context "when managing a component as an admin"

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
    click_link("New proposal")

    fill_in_i18n :proposal_title, "#proposal-title-tabs", en: new_title
    fill_in_i18n_editor :proposal_body, "#proposal-body-tabs", en: new_body
    fill_in :proposal_attachment_title, with: "FOO BAR"
    dynamically_attach_file(:proposal_attachment_file, Decidim::Dev.asset("city.jpeg"))
    click_button("Create")
    find("a.action-icon--edit-proposal").click

    expect(page).to have_content("city.jpeg")
    expect(page).to have_content("FOO BAR")
  end
end
