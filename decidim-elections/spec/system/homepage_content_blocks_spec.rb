# frozen_string_literal: true

require "spec_helper"

describe "Homepage votings content blocks", type: :system do
  let(:organization) { create(:organization) }
  let(:show_statistics) { true }
  let!(:promoted_voting) { create(:voting, :promoted, organization: organization) }

  before do
    create :content_block, organization: organization, scope_name: :homepage, manifest_name: :highlighted_votings
    switch_to_host(organization.host)
  end

  context "when there are multiple votings" do
    let!(:unpromoted_voting) { create(:voting, organization: organization) }
    let!(:promoted_external_voting) { create(:voting, :promoted) }

    it "includes active votings to the homepage" do
      visit decidim.root_path

      within "#highlighted-votings" do
        expect(page).to have_i18n_content(promoted_voting.title)
        expect(page).to have_i18n_content(unpromoted_voting.title)
        expect(page).not_to have_i18n_content(promoted_external_voting.title)
      end
    end
  end

  context "when there's only one voting" do
    it "redirects to the voting page" do
      visit decidim.root_path
      click_link "Votings"

      expect(page).to have_i18n_content(promoted_voting.title)
      expect(page).to have_i18n_content(promoted_voting.description)
      expect(page).to have_current_path(decidim_votings.voting_path(promoted_voting))
    end
  end
end
