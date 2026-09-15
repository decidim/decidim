# frozen_string_literal: true

require "spec_helper"

describe "Debates Breadcrumb" do
  include_context "with a component"
  let(:manifest_name) { "debates" }

  let!(:debate) { create(:debate, component:) }

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
    it "shows the correct information in breadcrumb (space, component, debate)" do
      click_on translated(debate.title), class: "card__list"

      within(".menu-bar") do
        expect(page).to have_text(translated(component.participatory_space.title))
        expect(page).to have_text(translated(component.name))
        expect(page).to have_text(translated(debate.title))
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

    it "shows the correct information in breadcrumb (space, component, debate)" do
      within(".menu-bar") do
        expect(page).to have_text(translated(component.participatory_space.title))
        expect(page).to have_text(translated(component.name))
        expect(page).to have_text(translated(debate.title))
      end
    end
  end
end
