# frozen_string_literal: true

require "spec_helper"

describe "CollaborativeTexts Breadcrumb" do
  include_context "with a component"
  let(:manifest_name) { "collaborative_texts" }
  let!(:component) do
    create(:collaborative_text_component,
           manifest:,
           participatory_space: participatory_process)
  end
  let!(:document) { create(:collaborative_text_document, :with_body, :published, component:) }

  before do
    visit_component
  end

  describe "index" do
    it "shows the correct information in breadcrumb (space, component)" do
      within(".menu-bar") do
        expect(page).to have_text(translated(component.participatory_space.title))
        expect(page).to have_text(translated(component.name))
      end
    end
  end

  describe "show" do
    it "shows the correct information in breadcrumb (space, component, document)" do
      click_on document.title

      within(".menu-bar") do
        expect(page).to have_text(translated(component.participatory_space.title))
        expect(page).to have_text(translated(component.name))
        expect(page).to have_text(translated(document.title))
      end
    end
  end
end
