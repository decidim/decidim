# frozen_string_literal: true

require "spec_helper"

describe "Single election redirect" do
  include_context "with a component"

  let(:manifest_name) { "elections" }
  let(:election_path) { Decidim::EngineRouter.main_proxy(component).election_path(election) }

  context "when there is a single published election" do
    let!(:election) { create(:election, :published, :with_internal_users_census, component:) }

    it "redirects to the election" do
      visit_component

      expect(page).to have_current_path(election_path, ignore_query: true)
    end
  end

  context "when there are multiple published elections" do
    let!(:election) { create(:election, :published, :with_internal_users_census, component:) }
    let!(:another_election) { create(:election, :published, :with_internal_users_census, component:) }

    it "shows the list of elections" do
      visit_component

      expect(page).to have_css("a.card__list", count: 2)
    end
  end

  context "when the only election is not published" do
    let!(:election) { create(:election, component:) }

    it "shows the elections index" do
      visit_component

      expect(page).to have_no_current_path(election_path, ignore_query: true)
      expect(page).to have_css("#elections")
    end
  end
end
