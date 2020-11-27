# frozen_string_literal: true

require "spec_helper"

describe "Private Participatory Processes", type: :system do
  let!(:organization) { create(:organization) }
  let!(:participatory_process) { create :participatory_process, :published, organization: organization }
  let!(:private_participatory_process) { create :participatory_process, :published, organization: organization, private_space: true }
  let!(:admin) { create(:user, :admin, :confirmed, organization: organization) }
  let!(:user) { create :user, :confirmed, organization: organization }
  let!(:other_user) { create :user, :confirmed, organization: organization }
  let!(:other_user_2) { create :user, :confirmed, organization: organization }
  let!(:participatory_space_private_user) { create :participatory_space_private_user, user: other_user, privatable_to: private_participatory_process }
  let!(:participatory_space_private_user_2) { create :participatory_space_private_user, user: other_user_2, privatable_to: private_participatory_process }
  let!(:share_token) { create :share_token, user: admin, organization: organization, token_for: private_participatory_process }

  context "when there are private participatory processes" do
    context "and no user is loged in" do
      before do
        switch_to_host(organization.host)
        visit decidim_participatory_processes.participatory_processes_path
      end

      it "lists only the not private participatory process" do
        within "#processes-grid" do
          within "#processes-grid h3" do
            expect(page).to have_content("1")
          end

          expect(page).to have_content(translated(participatory_process.title, locale: :en))
          expect(page).to have_selector(".card", count: 1)

          expect(page).to have_no_content(translated(private_participatory_process.title, locale: :en))
        end
      end
    end

    context "when user is loged in and is not a participatory space private user" do
      before do
        switch_to_host(organization.host)
        login_as user, scope: :user
        visit decidim_participatory_processes.participatory_processes_path
      end

      it "lists only the not private participatory process" do
        within "#processes-grid" do
          within "#processes-grid h3" do
            expect(page).to have_content("1")
          end

          expect(page).to have_content(translated(participatory_process.title, locale: :en))
          expect(page).to have_selector(".card", count: 1)

          expect(page).to have_no_content(translated(private_participatory_process.title, locale: :en))
        end
      end

      context "when the user is admin" do
        before do
          switch_to_host(organization.host)
          login_as admin, scope: :user
          visit decidim_participatory_processes.participatory_processes_path
        end

        it "lists private participatory processes" do
          within "#processes-grid" do
            within "#processes-grid h3" do
              expect(page).to have_content("2")
            end

            expect(page).to have_content(translated(participatory_process.title, locale: :en))
            expect(page).to have_content(translated(private_participatory_process.title, locale: :en))
            expect(page).to have_selector(".card", count: 2)
          end
        end
      end
    end

    context "when user is loged in and is participatory space private user" do
      before do
        switch_to_host(organization.host)
        login_as other_user, scope: :user
        visit decidim_participatory_processes.participatory_processes_path
      end

      it "lists private participatory processes" do
        within "#processes-grid" do
          within "#processes-grid h3" do
            expect(page).to have_content("2")
          end

          expect(page).to have_content(translated(participatory_process.title, locale: :en))
          expect(page).to have_content(translated(private_participatory_process.title, locale: :en))
          expect(page).to have_selector(".card", count: 2)
        end
      end

      it "links to the individual process page" do
        first(".card__link", text: translated(private_participatory_process.title, locale: :en)).click

        expect(page).to have_current_path decidim_participatory_processes.participatory_process_path(private_participatory_process)
        expect(page).to have_content "This is a private process"
      end
    end

    context "when a private participatory space has a valid share token and the sign up path is used with the token" do
      let(:sign_in_path) { decidim.new_user_registration_path(share_token: share_token.token) }

      before do
        switch_to_host(organization.host)
      end

      context "and no user is logged in" do
        it "redirects new registered user to space as private user" do
          visit sign_in_path

          fill_in :registration_user_name, with: "Nikola Tesla"
          fill_in :registration_user_nickname, with: "the-greatest-genius-in-history"
          fill_in :registration_user_email, with: "nikola.tesla@example.org"
          fill_in :registration_user_password, with: "sekritpass123"
          fill_in :registration_user_password_confirmation, with: "sekritpass123"
          page.check("registration_user_newsletter")
          page.check("registration_user_tos_agreement")
          within "form.new_user" do
            find("*[type=submit]").click
          end

          new_user = organization.users.last

          expect(page).to have_current_path decidim_participatory_processes.participatory_process_path(private_participatory_process)
          expect(private_participatory_process.users).to include(new_user)
        end
      end

      context "when user is loged in and is not a participatory space private user" do
        it "redirects new registered user to space as private user" do
          login_as user, scope: :user
          visit sign_in_path

          expect(page).to have_current_path decidim_participatory_processes.participatory_process_path(private_participatory_process)
          expect(private_participatory_process.users).to include(user)
        end
      end
    end
  end
end
