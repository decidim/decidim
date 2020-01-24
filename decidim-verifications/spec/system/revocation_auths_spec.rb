# frozen_string_literal: true

require "spec_helper"

describe "Authorizations revocation flow", type: :system do
  let!(:organization) do
    create(:organization, available_authorizations: [authorization])
  end
  let(:authorization) { "dummy_authorization_handler" }
  let(:admin) { create(:user, :admin, :confirmed, organization: organization) }
  let(:name) { "some_method" }
  let(:prev_year) { Date.today.prev_year }
  let(:user1) { create(:user, organization: organization) }
  let(:user2) { create(:user, organization: organization) }
  let(:user3) { create(:user, organization: organization) }
  let!(:granted_authorizations) do
    create(:authorization, created_at: prev_year, granted_at: prev_year, name: name, user: user1)
    create(:authorization, created_at: prev_year, granted_at: prev_year, name: name, user: user2)
    create(:authorization, created_at: prev_year, granted_at: prev_year, name: name, user: user3)
  end
  let(:authorizations) do
    Decidim::Verifications::Authorizations.new(
        organization: organization,
        granted: true
    ).query
  end

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin.root_path
    click_link "Participants"
    click_link "Verifications"
  end

  context "Showing revocation cell options" do
    context "when showing Admin / Participants / Verifications menu with granted authorizations" do
      it "allows the user to see Verification's revocation menu cell" do
        within ".container" do
          expect(page).to have_content(t("decidim.admin.menu.authorization_revocation.title").upcase!)
        end
      end
      it "allows the user to see Verification's revocation menu. Revoke all option " do
        within ".container" do
          expect(page).to have_content(t("decidim.admin.menu.authorization_revocation.button"))
        end
      end
      it "allows the user to see Verification's revocation menu. Before date option " do
        within ".container" do
          expect(page).to have_content(t("decidim.admin.menu.authorization_revocation.before_date_info"))
          expect(page).to have_content(t("decidim.admin.menu.authorization_revocation.button_before"))
        end
      end
      it "doesn't allow the user to see No Granted Authorizations info message" do
        within ".container" do
          expect(page).not_to have_content(t("decidim.admin.menu.authorization_revocation.no_data"))
        end
      end
    end

    context "when showing Admin / Participants / Verifications menu without granted authorizations" do
      let(:organization) do
        create(:organization, available_authorizations: [authorization])
      end
      let(:authorization) { "dummy_authorization_handler" }
      let(:granted_authorizations) { [ ] }
      it "allows the user to list all available authorization methods" do
        within ".container" do
          expect(page).to have_content(t("decidim.admin.menu.authorization_revocation.no_data"))
          expect(page).not_to have_content(t("decidim.admin.menu.authorization_revocation.button"))
          expect(page).not_to have_content(t("decidim.admin.menu.authorization_revocation.before_date_info"))
          expect(page).not_to have_content(t("decidim.admin.menu.authorization_revocation.button_before"))
        end
      end
    end
  end
end
