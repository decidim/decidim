# frozen_string_literal: true

require "spec_helper"

describe "Monitoring committee member manages votings" do
  include_context "when monitoring committee member manages voting"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_votings.votings_path
  end

  it_behaves_like "needs admin TOS accepted" do
    let(:user) { create(:user, :confirmed, organization:) }
  end

  context "when the user has not accepted the admin TOS" do
    let(:user) { create(:user, :confirmed, organization:) }

    it "shows a message to accept the admin TOS" do
      expect(page).to have_content("Please take a moment to review the admin terms of service")
    end
  end

  describe "when listing votings" do
    let(:other_voting) { create(:voting, organization:) }

    it "only lists the voting I am a monitoring committee member of" do
      within "#votings table" do
        expect(page).to have_text(translated(voting.title))
        expect(page).not_to have_text(translated(other_voting.title))
      end
    end
  end
end
