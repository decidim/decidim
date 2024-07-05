# frozen_string_literal: true

require "spec_helper"

require "decidim/admin/test/invite_participatory_space_admins_shared_examples"

describe "Invite process administrator" do
  let(:participatory_space) { create(:participatory_process) }
  let(:private_participatory_space) { create(:participatory_process, private_space: true) }
  let(:about_this_space_label) { "About this process" }
  let(:space_admins_label) { "Process admins" }
  let(:space_sidebar_label) { "Processes" }
  let(:role) { "Administrator" }

  before do
    switch_to_host organization.host
  end

  shared_examples "sees public space menu" do
    it "can access all sections" do
      within_admin_sidebar_menu do
        expect(page).to have_content("About this process")
        expect(page).to have_content("Landing page")
        expect(page).to have_content("Phases")
        expect(page).to have_content("Components")
        expect(page).to have_content("Categories")
        expect(page).to have_content("Attachments")
        expect(page).to have_content("Process admins")
        expect(page).not_to have_content("Private participants")
        expect(page).to have_content("Moderations")
      end
    end
  end

  shared_examples "sees private space menu" do
    it "can access all sections" do
      within_admin_sidebar_menu do
        expect(page).to have_content("About this process")
        expect(page).to have_content("Landing page")
        expect(page).to have_content("Phases")
        expect(page).to have_content("Components")
        expect(page).to have_content("Categories")
        expect(page).to have_content("Attachments")
        expect(page).to have_content("Process admins")
        expect(page).to have_content("Private participants")
        expect(page).to have_content("Moderations")
      end
    end
  end

  context "when the user does not exist" do
    before do
      perform_enqueued_jobs { invite_user }
    end

    it "asks for a password and nickname and redirects to the admin dashboard" do
      visit last_email_link

      within "form.new_user" do
        fill_in :invitation_user_nickname, with: "caballo_loco"
        fill_in :invitation_user_password, with: "decidim123456789"
        check :invitation_user_tos_agreement
        find("*[type=submit]").click
      end

      expect(page).to have_current_path "/admin/admin_terms/show"

      visit decidim_admin.admin_terms_show_path

      find_button("I agree with the terms").click

      click_link "Processes"

      within "div.table-scroll" do
        expect(page).to have_i18n_content(participatory_process.title)
        within find("tr", text: translated(participatory_process.title)) do
          click_link translated(participatory_process.title)
        end
      end
    end

    context "when the user does not exist" do
      before do
        perform_enqueued_jobs { invite_user }

        visit last_email_link

        within "form.new_user" do
          fill_in :invitation_user_nickname, with: "caballo_loco"
          fill_in :invitation_user_password, with: "decidim123456789"
          check :invitation_user_tos_agreement
          find("*[type=submit]").click
        end

        expect(page).to have_current_path "/admin/admin_terms/show"

        visit decidim_admin.admin_terms_show_path

        find_button("I agree with the terms").click

        click_link "Processes"
        let(:participatory_space_user_roles_path) { decidim_admin_participatory_processes.participatory_process_user_roles_path(participatory_space) }
        let(:new_button_label) { "New process admin" }

        within "div.table-scroll" do
          expect(page).to have_i18n_content(participatory_process.title)
          within find("tr", text: translated(participatory_process.title)) do
            click_link translated(participatory_process.title)
          end
        end
      end

      include_context "when inviting participatory space users"

      context "and is a public process" do
        it_behaves_like "sees public space menu"
      end

      context "and is a private process" do
        let(:participatory_process) { create(:participatory_process, private_space: true) }

        it_behaves_like "sees private space menu"
      end
    end
  end

  context "when the user already exists" do
    let(:email) { "administrator@example.org" }

    let!(:administrator) do
      create(:user, :confirmed, :admin_terms_accepted, email:, organization:)
    end

    before do
      perform_enqueued_jobs { invite_user }
    end

    it "redirects the administrator to the admin dashboard" do
      login_as administrator, scope: :user

      visit decidim_admin.root_path

      click_link "Processes"

      within "div.table-scroll" do
        expect(page).to have_i18n_content(participatory_process.title)
        expect(page).to have_i18n_content(participatory_process.title)
        within find("tr", text: translated(participatory_process.title)) do
          click_link translated(participatory_process.title)
        end
      end
    end

    context "when user exists in the organization" do
      before do
        perform_enqueued_jobs { invite_user }
        login_as administrator, scope: :user

        visit decidim_admin.root_path

        click_link "Processes"

        within "div.table-scroll" do
          expect(page).to have_i18n_content(participatory_process.title)
          expect(page).to have_i18n_content(participatory_process.title)
          within find("tr", text: translated(participatory_process.title)) do
            click_link translated(participatory_process.title)
          end
        end
      end

      context "and is a public process" do
        it_behaves_like "sees public space menu"
      end

      context "and is a private process" do
        let(:participatory_process) { create(:participatory_process, private_space: true) }

        it_behaves_like "sees private space menu"
      end
    end
  end

  it_behaves_like "inviting participatory space admins"
end
