# frozen_string_literal: true

shared_examples "inviting participatory space admins" do |check_members_page: true, check_landing_page: true|
  let(:role) { "Administrator" }

  before do
    switch_to_host organization.host
  end

  shared_examples "sees space without members menu" do
    it "can access all sections" do
      within_admin_sidebar_menu do
        expect(page).to have_content(about_this_space_label)
        expect(page).to have_content("Landing page") if check_landing_page
        expect(page).to have_content("Phases") if participatory_space.is_a?(Decidim::ParticipatoryProcess)
        expect(page).to have_content("Components")
        expect(page).to have_content("Attachments")
        expect(page).to have_content(space_admins_label)
        expect(page).to have_no_content("Members") if participatory_space.respond_to?(:has_members)
        expect(page).to have_content("Moderations")
      end
    end
  end

  shared_examples "sees space with members menu" do
    it "can access all sections" do
      within_admin_sidebar_menu do
        expect(page).to have_content(about_this_space_label)
        expect(page).to have_content("Landing page") if check_landing_page
        expect(page).to have_content("Phases") if participatory_space.is_a?(Decidim::ParticipatoryProcess)
        expect(page).to have_content("Components")
        expect(page).to have_content("Attachments")
        expect(page).to have_content(space_admins_label)
        expect(page).to have_content("Members") if participatory_space.respond_to?(:has_members)
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

      expect(page).to have_current_path decidim_admin.admin_terms_show_path

      visit decidim_admin.admin_terms_show_path

      find_button("I agree with the terms").click

      click_on space_sidebar_label

      within ".table-list" do
        expect(page).to have_i18n_content(participatory_space.title)
        within "tr", text: translated(participatory_space.title) do
          click_on translated(participatory_space.title)
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

        expect(page).to have_current_path decidim_admin.admin_terms_show_path

        visit decidim_admin.admin_terms_show_path

        find_button("I agree with the terms").click

        click_on space_sidebar_label

        within ".table-list" do
          expect(page).to have_i18n_content(participatory_space.title)
          within "tr", text: translated(participatory_space.title) do
            click_on translated(participatory_space.title)
          end
        end
      end

      context "and is a public space" do
        it_behaves_like "sees space without members menu"
      end

      if check_members_page
        context "and is a space with members" do
          let(:participatory_space) { members_participatory_space }

          it_behaves_like "sees space with members menu"
        end
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

      click_on space_sidebar_label

      within ".table-list" do
        expect(page).to have_i18n_content(participatory_space.title)
        expect(page).to have_i18n_content(participatory_space.title)
        within "tr", text: translated(participatory_space.title) do
          click_on translated(participatory_space.title)
        end
      end
    end

    it "selects the user role in the form" do
      edit_user(administrator.name)

      expect(page).to have_select("Role", selected: "Administrator")
    end

    context "when user exists in the organization" do
      before do
        perform_enqueued_jobs { invite_user }
        login_as administrator, scope: :user

        visit decidim_admin.root_path

        click_on space_sidebar_label

        within ".table-list" do
          expect(page).to have_i18n_content(participatory_space.title)
          expect(page).to have_i18n_content(participatory_space.title)
          within "tr", text: translated(participatory_space.title) do
            click_on translated(participatory_space.title)
          end
        end
      end

      context "and is a public space" do
        it_behaves_like "sees space without members menu"
      end

      if check_members_page
        context "and is a space with members" do
          let(:participatory_space) { members_participatory_space }

          it_behaves_like "sees space with members menu"
        end
      end
    end
  end
end
