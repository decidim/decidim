# frozen_string_literal: true

require "spec_helper"

describe "Private Participatory Processes" do
  let!(:organization) { create(:organization) }
  let!(:participatory_process) { create(:participatory_process, :published, organization:) }
  let!(:private_participatory_process) { create(:participatory_process, :published, organization:, private_space: true) }
  let!(:admin) { create(:user, :admin, :confirmed, organization:) }
  let!(:user) { create(:user, :confirmed, organization:) }
  let!(:other_user) { create(:user, :confirmed, organization:) }
  let!(:other_user2) { create(:user, :confirmed, organization:) }
  let!(:participatory_space_private_user) { create(:participatory_space_private_user, user: other_user, privatable_to: private_participatory_process) }
  let!(:participatory_space_private_user2) { create(:participatory_space_private_user, user: other_user2, privatable_to: private_participatory_process) }

  context "when there are private participatory processes" do
    context "and no user is logged in" do
      before do
        switch_to_host(organization.host)
        visit decidim_participatory_processes.participatory_processes_path(locale: I18n.locale)
      end

      it "lists only the not private participatory process" do
        within "#processes-grid" do
          within "#processes-grid h2" do
            expect(page).to have_content("1")
          end

          expect(page).to have_content(translated(participatory_process.title, locale: :en))
          expect(page).to have_css(".card__grid", count: 1)

          expect(page).to have_no_content(translated(private_participatory_process.title, locale: :en))
        end
      end
    end

    context "when user is logged" do
      context "when is not a participatory space private user" do
        before do
          switch_to_host(organization.host)
          login_as user, scope: :user
          visit decidim_participatory_processes.participatory_processes_path(locale: I18n.locale)
        end

        it "lists only the not private participatory process" do
          within "#processes-grid" do
            within "#processes-grid h2" do
              expect(page).to have_content("1")
            end

            expect(page).to have_content(translated(participatory_process.title, locale: :en))
            expect(page).to have_css(".card__grid", count: 1)

            expect(page).to have_no_content(translated(private_participatory_process.title, locale: :en))
          end
        end
      end

      context "when the user is admin" do
        before do
          switch_to_host(organization.host)
          login_as admin, scope: :user
          visit decidim_participatory_processes.participatory_processes_path(locale: I18n.locale)
        end

        it "lists private participatory processes" do
          within "#processes-grid" do
            within "#processes-grid h2" do
              expect(page).to have_content("2")
            end

            expect(page).to have_content(translated(participatory_process.title, locale: :en))
            expect(page).to have_content(translated(private_participatory_process.title, locale: :en))
            expect(page).to have_css(".card__grid", count: 2)
          end
        end

        it "shows the privacy warning in attachments admin" do
          visit decidim_admin_participatory_processes.participatory_process_attachments_path(private_participatory_process, locale: I18n.locale)
          within "#attachments" do
            expect(page).to have_content("Any participant could share this document to others")
          end
        end
      end
    end

    context "when user is logged in and is participatory space private user" do
      before do
        switch_to_host(organization.host)
        login_as other_user, scope: :user
        visit decidim_participatory_processes.participatory_processes_path(locale: I18n.locale)
      end

      it "lists private participatory processes" do
        within "#processes-grid" do
          within "#processes-grid h2" do
            expect(page).to have_content("2")
          end

          expect(page).to have_content(translated(participatory_process.title, locale: :en))
          expect(page).to have_content(translated(private_participatory_process.title, locale: :en))
          expect(page).to have_css(".card__grid", count: 2)
        end
      end

      it "links to the individual process page" do
        first(".card__grid-text", text: translated(private_participatory_process.title, locale: :en)).click

        expect(page).to have_current_path decidim_participatory_processes.participatory_process_path(private_participatory_process, locale: I18n.locale)
        expect(page).to have_content "This is a private process"
      end
    end
  end
end
