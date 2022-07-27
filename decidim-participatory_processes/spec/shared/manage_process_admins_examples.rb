# frozen_string_literal: true

shared_examples "manage process admins examples" do
  let(:other_user) { create :user, organization:, email: "my_email@example.org" }

  let!(:process_admin) do
    create :process_admin,
           :confirmed,
           organization:,
           participatory_process:
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_participatory_processes.edit_participatory_process_path(participatory_process)
    click_link "Process admins"
  end

  it "shows process admin list" do
    within "#process_admins table" do
      expect(page).to have_content(process_admin.email)
    end
  end

  it "creates a new process admin" do
    find(".card-title a.new").click

    within ".new_participatory_process_user_role" do
      fill_in :participatory_process_user_role_email, with: other_user.email
      fill_in :participatory_process_user_role_name, with: "John Doe"
      select "Administrator", from: :participatory_process_user_role_role

      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")

    within "#process_admins table" do
      expect(page).to have_content(other_user.email)
    end
  end

  describe "when managing different users" do
    let!(:user_role2) { create(:participatory_process_user_role, participatory_process:, user: other_user) }

    before do
      visit current_path
    end

    it "updates a process admin" do
      within "#process_admins" do
        within find("#process_admins tr", text: other_user.email) do
          click_link "Edit"
        end
      end

      within ".edit_participatory_process_user_roles" do
        select "Administrator", from: :participatory_process_user_role_role

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "#process_admins table" do
        expect(page).to have_content("Administrator")
      end
    end

    it "deletes a participatory_process_user_role" do
      within find("#process_admins tr", text: other_user.email) do
        accept_confirm { click_link "Delete" }
      end

      expect(page).to have_admin_callout("successfully")

      within "#process_admins table" do
        expect(page).to have_no_content(other_user.email)
      end
    end

    context "when the user has not accepted the invitation" do
      before do
        form = Decidim::ParticipatoryProcesses::Admin::ParticipatoryProcessUserRoleForm.from_params(
          name: "test",
          email: "test@example.org",
          role: "admin"
        )

        Decidim::ParticipatoryProcesses::Admin::CreateParticipatoryProcessAdmin.call(
          form,
          user,
          participatory_process
        )

        visit current_path
      end

      it "resends the invitation to the user" do
        within find("#process_admins tr", text: "test@example.org") do
          click_link "Resend invitation"
        end

        expect(page).to have_admin_callout("successfully")
      end
    end
  end
end
