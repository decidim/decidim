# frozen_string_literal: true

require "spec_helper"

describe "Single debate redirect" do
  include_context "with a component"

  let(:manifest_name) { "debates" }
  let(:debate_path) { Decidim::EngineRouter.main_proxy(component).debate_path(debate) }

  context "when there is a single debate" do
    let!(:debate) { create(:debate, component:) }

    it "redirects to the debate" do
      visit_component

      expect(page).to have_current_path(debate_path, ignore_query: true)
    end
  end

  context "when there are multiple debates" do
    let!(:debate) { create(:debate, component:) }
    let!(:another_debate) { create(:debate, component:) }

    it "shows the list of debates" do
      visit_component

      expect(page).to have_css("a.card__list", count: 2)
    end
  end

  context "when creating debates is enabled" do
    let!(:component) { create(:debates_component, :with_creation_enabled, participatory_space:) }
    let!(:debate) { create(:debate, component:) }

    before do
      login_as user, scope: :user
    end

    it "shows the index with the create debate action" do
      visit_component

      expect(page).to have_current_path(Decidim::EngineRouter.main_proxy(component).root_path, ignore_query: true)
      expect(page).to have_link("New debate")
    end
  end
end
