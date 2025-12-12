# frozen_string_literal: true

require "spec_helper"

describe "Collaborative texts breadcrumbs" do
  include_context "with a component"
  let(:manifest_name) { "collaborative_texts" }
  let!(:component) do
    create(:collaborative_text_component,
           manifest:,
           participatory_space: participatory_process)
  end

  let!(:document) { create(:collaborative_text_document, :published, component:, body:) }
  let(:body) do
    "<h2>First title</h2>
      <p>First <b>paragraph</b></p>
      <p>Second paragraph</p>
      <h2>Second title</h2>
      <p>Third paragraph</p>"
  end

  before do
    visit_component
  end

  describe "index" do
    it "shows the correct information in breadcrumb (space, component)" do
      within(".menu-bar") do
        expect(page).to have_content(translated(component.participatory_space.title))
        expect(page).to have_content(translated(component.name))
      end
    end
  end

  describe "show" do
    it "shows the correct information in breadcrumb (space, component, document)" do
      click_on document.title

      within(".menu-bar") do
        expect(page).to have_content(translated(component.participatory_space.title))
        expect(page).to have_content(translated(component.name))
        expect(page).to have_content(translated(document.title))
      end
    end
  end
end
