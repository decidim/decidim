# frozen_string_literal: true

require "spec_helper"

describe "Admin invite" do
  let(:form) do
    Decidim::System::RegisterOrganizationForm.new(params)
  end

  let(:params) do
    {
      name: "Gotham City",
      short_name: "GothamCity",
      reference_prefix: "JKR",
      host: "decide.lvh.me",
      organization_admin_name: "Fiorello Henry La Guardia",
      organization_admin_email: "f.laguardia@example.org",
      available_locales: ["en"],
      default_locale: "en",
      users_registration_mode: "enabled",
      smtp_settings: {
        "address" => "decide.lvh.me",
        "port" => "25",
        "user_name" => "f.laguardia",
        "password" => Decidim::AttributeEncryptor.encrypt("password"),
        "from" => "no-reply@example.org"
      },
      file_upload_settings: Decidim::OrganizationSettings.default(:upload)
    }
  end

  before do
    expect do
      perform_enqueued_jobs { Decidim::System::CreateOrganization.new(form).call }
    end.to broadcast(:ok)

    switch_to_host("decide.lvh.me")
  end

  describe "Accept an invitation" do
    context "when users_registration_mode enabled" do
      before do
        Decidim::Organization.last.update!(users_registration_mode: "enabled")
        visit last_email_link
      end

      it "has password" do
        expect(page).to have_css "#invitation_user_password"
      end

      it "asks for a password and nickname and redirects to the organization dashboard" do
        within "form.new_user" do
          fill_in :invitation_user_nickname, with: "caballo_loco"
          fill_in :invitation_user_password, with: "decidim123456789"
          check :invitation_user_tos_agreement
          find("*[type=submit]").click
        end

        expect(page).to have_admin_callout "Invitation accepted successfully. You are now signed in."

        expect(page).to have_current_path decidim_admin.admin_terms_show_path
      end

      it "shows error when password not valid" do
        within "form.new_user" do
          fill_in :invitation_user_nickname, with: "caballo_loco"
          check :invitation_user_tos_agreement
          find("*[type=submit]").click
        end

        within "div.user-password" do
          expect(page).to have_text "The password is too short."
        end
      end
    end

    context "when users_registration_mode existing" do
      before do
        Decidim::Organization.last.update!(users_registration_mode: "existing")
        visit last_email_link
      end

      it "has password" do
        expect(page).to have_css "#invitation_user_password"
      end

      it "asks for a password and nickname and redirects to the organization dashboard" do
        within "form.new_user" do
          fill_in :invitation_user_nickname, with: "caballo_loco"
          fill_in :invitation_user_password, with: "decidim123456789"
          check :invitation_user_tos_agreement
          find("*[type=submit]").click
        end

        expect(page).to have_admin_callout "Invitation accepted successfully. You are now signed in."

        expect(page).to have_current_path decidim_admin.admin_terms_show_path
      end

      it "shows error when password not valid" do
        within "form.new_user" do
          fill_in :invitation_user_nickname, with: "caballo_loco"
          check :invitation_user_tos_agreement
          find("*[type=submit]").click
        end

        within "div.user-password" do
          expect(page).to have_text "The password is too short."
        end
      end
    end

    context "when users_registration_mode disabled" do
      before do
        Decidim::Organization.last.update!(users_registration_mode: "disabled")
        visit last_email_link
      end

      it "has no password" do
        expect(page).to have_no_css "#invitation_user_password"
      end

      it "asks for nickname and redirects to the organization dashboard" do
        within "form.new_user" do
          fill_in :invitation_user_nickname, with: "caballo_loco"
          check :invitation_user_tos_agreement
          find("*[type=submit]").click
        end

        expect(page).to have_admin_callout "Invitation accepted successfully. You are now signed in."

        expect(page).to have_current_path decidim_admin.admin_terms_show_path
      end
    end

    it "displays admin password requirements" do
      visit last_email_link

      expect(page).to have_text("15 characters minimum")
      expect(page).to have_text("must contain at least 5 different characters")
      expect(page).to have_text("must not be too common")
      expect(page).to have_text("must be different from your name, nickname, email, the organization's host")
      expect(page).to have_text("must be different from your old passwords")
    end

    it "rejects passwords that are too short for admin" do
      visit last_email_link

      fill_in :invitation_user_nickname, with: "caballo_loco"
      fill_in :invitation_user_password, with: "short123"
      check :invitation_user_tos_agreement
      click_on "Save"

      expect(page).to have_text("password is too short")
    end

    it "rejects passwords containing the user's name" do
      visit last_email_link

      fill_in :invitation_user_nickname, with: "caballo_loco"
      fill_in :invitation_user_password, with: "Fiorello123456789!"
      check :invitation_user_tos_agreement
      click_on "Save"

      expect(page).to have_text("is too similar to your name")
    end

    it "rejects passwords with less than 5 unique characters" do
      visit last_email_link

      fill_in :invitation_user_nickname, with: "caballo_loco"
      fill_in :invitation_user_password, with: "aaaaaaaaaaaaaaa!"
      check :invitation_user_tos_agreement
      click_on "Save"

      expect(page).to have_text("does not have enough unique characters")
    end
  end

  context "when inviting a regular user" do
    let(:organization) { create(:organization, host: "new-decide.lvh.me") }
    let(:inviter) { create(:user, :confirmed, :admin, organization:) }

    let!(:invited_user) do
      perform_enqueued_jobs do
        Decidim::User.invite!(
          {
            organization:,
            name: "Invited User",
            email: "invited_user@example.org"
          },
          inviter
        )
      end
    end

    it "displays regular user password requirements in help text" do
      switch_to_host("new-decide.lvh.me")
      visit last_email_link

      expect(page).to have_text("10 characters minimum")
      expect(page).to have_text("must contain at least 5 different characters")
      expect(page).to have_text("must not be too common")
      expect(page).to have_text("must be different from your name, nickname, email and the organization's host")
      expect(page).to have_no_text("must be different from your old passwords")
    end

    it "allows accepting invitation with valid user password" do
      switch_to_host("new-decide.lvh.me")
      visit last_email_link

      fill_in :invitation_user_nickname, with: "invited_user"
      fill_in :invitation_user_password, with: "decidim123"
      check :invitation_user_tos_agreement
      click_on "Save"

      expect(page).to have_text("Invitation accepted successfully. You are now signed in.")
      expect(Decidim::User.find_by(email: "invited_user@example.org")).not_to be_admin
    end
  end

  context "when admin_password_strong is disabled" do
    let(:organization) { create(:organization, host: "new-decide.lvh.me") }
    let(:inviter) { create(:user, :confirmed, :admin, organization:) }
    let!(:invited_admin) do
      perform_enqueued_jobs do
        Decidim::User.invite!(
          {
            organization:,
            name: "Invited Admin",
            email: "invited_admin@example.org",
            admin: true
          },
          inviter
        )
      end
    end

    before do
      allow(Decidim.config).to receive(:admin_password_strong).and_return(false)
    end

    it "displays regular password requirements for admins" do
      switch_to_host("new-decide.lvh.me")
      visit last_email_link

      expect(page).to have_text("10 characters minimum")
      expect(page).to have_text("must contain at least 5 different characters")
      expect(page).to have_text("must be different from your name, nickname, email and the organization's host")
      expect(page).to have_no_text("must be different from your old passwords")
    end
  end

  context "with invalid invitation token" do
    it "shows error for invalid token" do
      visit decidim.accept_user_invitation_path(invitation_token: "invalid_token")

      expect(page).to have_text("The invitation token provided is not valid")
    end
  end
end
