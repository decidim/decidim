# frozen_string_literal: true

RSpec.shared_examples "manage participatory space share tokens" do
  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  def visit_share_tokens_path
    visit participatory_space_path
    click_on "Share tokens"
  end

  context "when visiting the share_tokens page for the participatory space" do
    let!(:share_token) { create(:share_token, token_for: participatory_space, organization:, user:, registered_only: true) }

    before do
      visit participatory_space_path
    end

    it "has a share button that opens the share tokens admin" do
      click_on "Share"
      expect(page).to have_content("Sharing tokens for: #{translated(participatory_space.title)}")
      expect(page).to have_css("tbody tr", count: 1)
      expect(page).to have_content(share_token.token)
    end
  end
end
