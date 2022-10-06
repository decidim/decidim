# frozen_string_literal: true

shared_examples "manage conference admins examples" do
  let(:other_user) { create :user, organization:, email: "my_email@example.org" }

  let!(:conference_admin) do
    create :conference_admin,
           :confirmed,
           organization:,
           conference:
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_conferences.edit_conference_path(conference)
    click_link "Conference admins"
  end

  it "shows conference admin list" do
    within "#conference_admins table" do
      expect(page).to have_content(conference_admin.email)
    end
  end

  it "creates a new conference admin" do
    find(".card-title a.new").click

    within ".new_conference_user_role" do
      fill_in :conference_user_role_email, with: other_user.email
      fill_in :conference_user_role_name, with: "John Doe"
      select "Administrator", from: :conference_user_role_role

      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")

    within "#conference_admins table" do
      expect(page).to have_content(other_user.email)
    end
  end

  describe "when managing different users" do
    before do
      create(:conference_user_role, conference:, user: other_user)
      visit current_path
    end

    it "updates a conference admin" do
      within "#conference_admins" do
        within find("#conference_admins tr", text: other_user.email) do
          click_link "Edit"
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
    end

    it "deletes a conference_user_role" do
      within find("#conference_admins tr", text: other_user.email) do
        accept_confirm { click_link "Delete" }
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
        )

        Decidim::Conferences::Admin::CreateConferenceAdmin.call(
          form,
          user,
          conference
        )

        visit current_path
      end

      it "resends the invitation to the user" do
        within find("#conference_admins tr", text: "test@example.org") do
          click_link "Resend invitation"
        end

        expect(page).to have_admin_callout("successfully")
      end
    end
  end
end
