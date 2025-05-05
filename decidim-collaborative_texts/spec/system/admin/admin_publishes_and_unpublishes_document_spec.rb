# frozen_string_literal: true

require "spec_helper"

describe "Admin publish and unpublish documents" do
  let(:manifest_name) { "collaborative_texts" }
  let(:title) { "This is my document new title" }
  let(:body) { Faker::HTML.paragraph }

  include_context "when managing a component as an admin" do
    let!(:component) { create(:collaborative_text_component, participatory_space:) }
  end

  before do
    click_on "New text"
    fill_in "Title", with: title
    fill_in_editor :document_body, with: body
    click_on "Create"
  end

  it "publishes and unpublish a document" do
    expect(page).to have_content("Collaborative texts")
    expect(page).to have_content("New text")
    expect(page).to have_content("Configure")

    expect(page).to have_css(".action-icon--publish")
    click_on "Publish", match: :first
    expect(page).to have_admin_callout "Document successfully published"

    expect(page).to have_css(".action-icon--unpublish")
    click_on "Unpublish", match: :first
    expect(page).to have_admin_callout "Document successfully unpublished"
  end

  context "when unpublished document" do
    before do
      visit_component
    end

    it "displays unpublished documents in public view" do
      expect(page).to have_content(title)
    end

    context "and non-admin user" do
      let(:regular_user) { create(:user, :confirmed, organization:) }

      before do
        login_as regular_user, scope: :user
        visit_component
      end

      it "does not display unpublished documents in public view" do
        expect(page).to have_no_content(title)
      end
    end
  end

  def visit_component
    page.visit main_component_path(component)
  end
end
