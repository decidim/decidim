# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/has_contextual_help"

describe "Votings", type: :system do
  let(:organization) { create(:organization) }

  before do
    switch_to_host(organization.host)
  end

  it_behaves_like "shows contextual help" do
    let(:index_path) { decidim_votings.votings_path }
    let(:manifest_name) { :votings }
  end

  context "when ordering by 'Most recent'" do
    let!(:older_voting) do
      create(:voting, :published, organization: organization, created_at: 1.month.ago)
    end

    let!(:recent_voting) do
      create(:voting, :published, organization: organization, created_at: Time.now.utc)
    end

    before do
      switch_to_host(organization.host)
    end

    it_behaves_like "editable content for admins" do
      let(:target_path) { visit decidim_votings.votings_path }
    end

    context "when requesting the votings path" do
      before do
        visit decidim_votings.votings_path
      end

      it "lists the votings ordered by created at" do
        within ".order-by" do
          expect(page).to have_selector("ul[data-dropdown-menu$=dropdown-menu]", text: "Random")
          page.find("a", text: "Random").click
          click_link "Most recent"
        end

        expect(page).to have_selector("#votings .card-grid .column:first-child", text: recent_voting.title[:en])
        expect(page).to have_selector("#votings .card-grid .column:last-child", text: older_voting.title[:en])
      end
    end
  end

  context "when ordering by 'Random'" do
    let!(:votings) { create_list(:voting, 2, :published, organization: organization) }

    before do
      switch_to_host(organization.host)
      visit decidim_votings.votings_path
    end

    it "Shows all votings" do
      within ".order-by" do
        expect(page).to have_selector("ul[data-dropdown-menu$=dropdown-menu]", text: "Random")
      end

      expect(page).to have_selector(".card--voting", count: 2)
      expect(page).to have_content(translated(votings.first.title))
      expect(page).to have_content(translated(votings.last.title))
    end
  end
end
