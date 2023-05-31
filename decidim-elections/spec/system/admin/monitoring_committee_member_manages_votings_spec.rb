# frozen_string_literal: true

require "spec_helper"

describe "Monitoring committee member manages votings", type: :system do
  include_context "when monitoring committee member manages voting"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_votings.votings_path
  end

  describe "when listing votings" do
    let(:other_voting) { create(:voting, organization:) }

    it "only lists the voting I'm a monitoring committee member of" do
      within "#votings table" do
        expect(page).to have_text(translated(voting.title))
        expect(page).not_to have_text(translated(other_voting.title))
      end
    end
  end
end
