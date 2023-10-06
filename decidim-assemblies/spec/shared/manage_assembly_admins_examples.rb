# frozen_string_literal: true

shared_examples "manage assembly admins examples" do
  let(:other_user) { create(:user, organization:, email: "my_email@example.org") }

  let!(:assembly_admin) do
    create(:assembly_admin,
           :confirmed,
           organization:,
           assembly:)
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_assemblies.edit_assembly_path(assembly)
    within_admin_sidebar_menu do
      click_link "Assembly admins"
    end
  end

  it "shows assembly admin list" do
    within "#assembly_admins table" do
      expect(page).to have_content(assembly_admin.email)
    end
  end

  it "creates a new assembly admin" do
    click_link "New assembly admin"

    within ".new_assembly_user_role" do
      fill_in :assembly_user_role_email, with: other_user.email
      fill_in :assembly_user_role_name, with: "John Doe"
      select "Administrator", from: :assembly_user_role_role

      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")

    within "#assembly_admins table" do
      expect(page).to have_content(other_user.email)
    end
  end

  describe "when managing different users" do
    before do
      create(:assembly_user_role, assembly:, user: other_user)
      visit current_path
    end

    it "updates an assembly admin" do
      within "#assembly_admins" do
        within find("#assembly_admins tr", text: other_user.email) do
          click_link "Edit"
        end
      end

      within ".edit_assembly_user_roles" do
        select "Collaborator", from: :assembly_user_role_role

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "#assembly_admins table" do
        expect(page).to have_content("Collaborator")
      end
    end

    it "deletes an assembly_user_role" do
      within find("#assembly_admins tr", text: other_user.email) do
        accept_confirm { click_link "Delete" }
      end

      expect(page).to have_admin_callout("successfully")

      within "#assembly_admins table" do
        expect(page).not_to have_content(other_user.email)
      end
    end

    context "when the user has not accepted the invitation" do
      before do
        form = Decidim::Assemblies::Admin::AssemblyUserRoleForm.from_params(
          name: "test",
          email: "test@example.org",
          role: "admin"
        ).with_context(current_user: user)

        Decidim::Admin::ParticipatorySpace::CreateAdmin.call(form, assembly,
                                                             event_class: Decidim::RoleAssignedToAssemblyEvent,
                                                             event: "decidim.events.assembly.role_assigned",
                                                             role_class: Decidim::AssemblyUserRole)

        visit current_path
      end

      it "resends the invitation to the user" do
        within find("#assembly_admins tr", text: "test@example.org") do
          click_link "Resend invitation"
        end

        expect(page).to have_admin_callout("successfully")
      end
    end
  end
end
