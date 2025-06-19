# frozen_string_literal: true

shared_examples "manage conference admins examples" do
  let(:other_user) { create(:user, organization:, email: "my_email@example.org") }
  let(:attributes) { attributes_for(:user, organization:) }

  let!(:conference_admin) do
    create(:conference_admin,
           :confirmed,
           organization:,
           conference:)
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_conferences.edit_conference_path(conference)
    within_admin_sidebar_menu do
      click_on "Conference admins"
    end
  end

  it "shows conference admin list" do
    within "#conference_admins table" do
      expect(page).to have_content(conference_admin.email)
    end
  end

  it "creates a new conference admin", versioning: true do
    click_on "New conference admin"

    within ".new_conference_user_role" do
      fill_in :conference_user_role_email, with: other_user.email
      fill_in :conference_user_role_name, with: attributes[:name]
      select "Administrator", from: :conference_user_role_role

      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")

    within "#conference_admins table" do
      expect(page).to have_content(other_user.email)
    end
    visit decidim_admin.root_path
    expect(page).to have_content("invited #{other_user.name} to the #{translated(conference.title)} conference")
  end

  describe "when managing different users" do
    before do
      create(:conference_user_role, conference:, user: other_user)
      visit current_path
    end

    it "updates a conference admin", versioning: true do
      within "#conference_admins" do
        within "#conference_admins tr", text: other_user.email do
          find("button[data-component='dropdown']").click
          click_on "Edit"
        end
      end

      within ".edit_conference_user_roles" do
        select "Collaborator", from: :conference_user_role_role

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "#conference_admins table" do
        expect(page).to have_content("Collaborator")
      end
      visit decidim_admin.root_path
      expect(page).to have_content("changed the role of #{other_user.name} in the #{translated(conference.title)} conference")
    end

    it "deletes a conference_user_role" do
      within "#conference_admins tr", text: other_user.email do
        find("button[data-component='dropdown']").click
        accept_confirm { click_on "Delete" }
      end

      expect(page).to have_admin_callout("successfully")

      within "#conference_admins table" do
        expect(page).to have_no_content(other_user.email)
      end
    end

    context "when the user has not accepted the invitation" do
      before do
        form = Decidim::Conferences::Admin::ConferenceUserRoleForm.from_params(
          name: "test",
          email: "test@example.org",
          role: "admin"
        ).with_context(current_user: user)

        Decidim::Admin::ParticipatorySpace::CreateAdmin.call(
          form,
          conference,
          role_class: Decidim::ConferenceUserRole,
          event: "decidim.events.conferences.role_assigned",
          event_class: Decidim::Conferences::ConferenceRoleAssignedEvent
        )

        visit current_path
      end

      it "resends the invitation to the user" do
        within "#conference_admins tr", text: "test@example.org" do
          find("button[data-component='dropdown']").click
          click_on "Resend invitation"
        end

        expect(page).to have_admin_callout("successfully")
      end
    end
  end
end
