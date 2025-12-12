# frozen_string_literal: true

require "spec_helper"

describe "debates breadcrumbs" do
  include_context "with a component"
  let(:manifest_name) { "debates" }

  let(:description) { generate_localized_description(:debate_description) }
  let(:information_updates) { generate_localized_description(:information_updates) }
  let(:instructions) { generate_localized_description(:instructions) }
  let!(:debate) { create(:debate, component:, description:, information_updates:, instructions:) }

  before do
    visit_component
  end

  describe "index" do
    it "shows the correct information in breadcrumb" do
      within(".menu-bar") do
        expect(page).to have_content(translated(component.participatory_space.title))
        expect(page).to have_content(translated(component.name))
      end
    end
  end

  describe "show" do
    it "shows the correct information in breadcrumb" do
      click_on translated(debate.title), class: "card__list"

      within(".menu-bar") do
        expect(page).to have_content(translated(component.participatory_space.title))
        expect(page).to have_content(translated(component.name))
        expect(page).to have_content(translated(debate.title))
      end
    end
  end

  describe "versions", versioning: true do
    let(:additional_description) { generate_localized_description(:debate_description) }

    before do
      Decidim.traceability.update!(
        debate,
        "Dummy author",
        description: additional_description
      )
      click_on translated(debate.title), class: "card__list"
      click_on "see other versions"
    end

    it "shows the correct information in breadcrumb" do
      within(".menu-bar") do
        expect(page).to have_content(translated(component.participatory_space.title))
        expect(page).to have_content(translated(component.name))
        expect(page).to have_content(translated(debate.title))
      end
    end
  end
end
