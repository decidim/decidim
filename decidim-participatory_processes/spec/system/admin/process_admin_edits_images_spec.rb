# frozen_string_literal: true

require "spec_helper"

describe "process admin editing images" do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { create(:user, :admin, organization:) }
  let(:organization) { create(:organization) }
  let(:process) { create(:participatory_process, organization:) }
  let(:creation_enabled?) { true }
  let(:new_title) { "This is my proposal new title" }
  let(:new_body) { "This is my proposal new body" }
  let(:image_filename) { "city2.jpeg" }
  let(:document_filename) { "Exampledocument.pdf" }
  let(:document_path) { Decidim::Dev.asset(document_filename) }
  let(:image_path) { Decidim::Dev.asset(image_filename) }
  let(:context) { {} }
  let(:permission_action) { Decidim::PermissionAction.new(**action) }
  let(:process_admin) { create(:process_admin, participatory_process: process) }

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

  it "can attach a images on proposals" do
    visit_component_admin
    click_on("New proposal")

    fill_in_i18n :proposal_title, "#proposal-title-tabs", en: new_title
    fill_in_i18n_editor :proposal_body, "#proposal-body-tabs", en: new_body
    dynamically_attach_file(:proposal_documents, image_path)
    dynamically_attach_file(:proposal_documents, document_path)

    click_on("Create")
    find("a.action-icon--edit-proposal").click

    expect(page).to have_content(image_filename)
    expect(page).to have_content(document_filename)
  end
end
