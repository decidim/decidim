# frozen_string_literal: true

require "spec_helper"

describe "Authorizations revocation flow", type: :system do
  let!(:organization) do
    create(:organization, available_authorizations: [authorization])
  end
  let(:authorization) { "dummy_authorization_handler" }
  let(:admin) { create(:user, :admin, :confirmed, organization: organization) }
  let(:name) { "some_method" }
  let(:prev_year) { Time.zone.today.prev_year }
  let(:prev_month) { Time.zone.today.prev_month }
  let(:prev_week) { Time.zone.today.prev_week }
  let(:user1) { create(:user, organization: organization) }
  let(:user2) { create(:user, organization: organization) }
  let(:user3) { create(:user, organization: organization) }
  let(:user4) { create(:user, organization: organization) }
  let(:user5) { create(:user, organization: organization) }
  let!(:granted_authorizations) do
    create(:authorization, created_at: prev_month, granted_at: prev_month, name: name, user: user1)
    create(:authorization, created_at: prev_year, granted_at: prev_year, name: name, user: user2)
    create(:authorization, created_at: prev_year, granted_at: prev_year, name: name, user: user3)
  end
  let!(:ungranted_authorizations) do
    create(:authorization, created_at: prev_month, granted_at: nil, name: name, user: user4)
    create(:authorization, created_at: prev_year, granted_at: nil, name: name, user: user5)
  end
  let(:get_all_authorizations) do
    Decidim::Verifications::Authorizations.new(
      organization: organization
    ).query
  end
  let(:get_granted_authorizations) do
    Decidim::Verifications::Authorizations.new(
      organization: organization,
      granted: true
    ).query
  end
  let(:get_ungranted_authorizations) do
    Decidim::Verifications::Authorizations.new(
      organization: organization,
      granted: nil
    ).query
  end

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin.root_path
    click_link "Participants"
    click_link "Authorizations"
  end

  context "when showing revocation cell" do
    context "when showing Admin / Participants / Verifications menu with granted authorizations" do
      it "allows the user to see Verification's revocation menu cell" do
        within ".container" do
          expect(page).to have_content(t("decidim.admin.menu.authorization_revocation.title"))
        end
      end

      it "allows the user to see Verification's revocation menu. Revoke all option" do
        within ".container" do
          expect(page).to have_content(t("decidim.admin.menu.authorization_revocation.button"))
        end
      end

      it "allows the user to see Verification's revocation menu. Before date option" do
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
      let(:granted_authorizations) { [] }

      it "allow the user to see No Granted Authorizations info message" do
        within ".container" do
          expect(page).to have_content(t("decidim.admin.menu.authorization_revocation.no_data"))
        end
      end

      it "doesn't allow the user to see Authorization's revocation options" do
        within ".container" do
          expect(page).not_to have_content(t("decidim.admin.menu.authorization_revocation.button"))
          expect(page).not_to have_content(t("decidim.admin.menu.authorization_revocation.before_date_info"))
          expect(page).not_to have_content(t("decidim.admin.menu.authorization_revocation.button_before"))
        end
      end
    end
  end

  context "when clicking revocating authorizations. Prompts" do
    context "when clicking Revoke All authorizations option" do
      it "appears revoke all confirmation dialog" do
        within ".container" do
          message = dismiss_confirm do
            click_link(t("decidim.admin.menu.authorization_revocation.button"))
          end
          expect(message).to eq(t("decidim.admin.menu.authorization_revocation.destroy.confirm_all"))
        end
      end

      it "doesnt appear revoke before confirmation dialog" do
        within ".container" do
          message = dismiss_confirm do
            click_link(t("decidim.admin.menu.authorization_revocation.button"))
          end
          expect(message).not_to eq(t("decidim.admin.menu.authorization_revocation.destroy.confirm"))
        end
      end
    end

    context "when clicking Revoke Before Date authorizations option" do
      it "appears revoke before confirmation dialog" do
        within ".container" do
          message = dismiss_confirm do
            click_button(t("decidim.admin.menu.authorization_revocation.button_before"))
          end
          expect(message).to eq(t("decidim.admin.menu.authorization_revocation.destroy.confirm"))
        end
      end

      it "doesnt appear revoke all confirmation dialog" do
        within ".container" do
          message = dismiss_confirm do
            click_button(t("decidim.admin.menu.authorization_revocation.button_before"))
          end
          expect(message).not_to eq(t("decidim.admin.menu.authorization_revocation.destroy.confirm_all"))
        end
      end
    end
  end

  context "when clicking revoke all authorizations option with admin user" do
    it "shows an informative message to the user with all authorizations revoked ok" do
      accept_confirm do
        click_link(t("decidim.admin.menu.authorization_revocation.button"))
      end
      expect(page).to have_content(t("authorization_revocation.destroy_ok", scope: "decidim.admin.menu"))
      expect(page).not_to have_content(t("authorization_revocation.destroy_nok", scope: "decidim.admin.menu"))
    end
  end

  context "when clicking revoke before date authorizations option with admin user" do
    it "shows an informative message to the user with before date authorizations revoked ok" do
      accept_confirm do
        click_button(t("decidim.admin.menu.authorization_revocation.button_before"))
      end
      expect(page).to have_content(t("authorization_revocation.destroy_ok", scope: "decidim.admin.menu"))
      expect(page).not_to have_content(t("authorization_revocation.destroy_nok", scope: "decidim.admin.menu"))
    end
  end
end
