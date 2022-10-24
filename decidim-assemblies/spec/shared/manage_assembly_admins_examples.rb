# frozen_string_literal: true

shared_examples "manage assembly admins examples" do
  let(:other_user) { create :user, organization:, email: "my_email@example.org" }

  let!(:assembly_admin) do
    create :assembly_admin,
           :confirmed,
           organization:,
           assembly:
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_assemblies.edit_assembly_path(assembly)
    click_link "Assembly admins"
  end

  it "shows assembly admin list" do
    within "#assembly_admins table" do
      expect(page).to have_content(assembly_admin.email)
    end
  end

  it "creates a new assembly admin" do
    find(".card-title a.new").click

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

    it "updates a assembly admin" do
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

    it "deletes a assembly_user_role" do
      within find("#assembly_admins tr", text: other_user.email) do
        accept_confirm { click_link "Delete" }
      end

      expect(page).to have_admin_callout("successfully")

      within "#assembly_admins table" do
        expect(page).to have_no_content(other_user.email)
      end
    end

    context "when the user has not accepted the invitation" do
      before do
        form = Decidim::Assemblies::Admin::AssemblyUserRoleForm.from_params(
          name: "test",
          email: "test@example.org",
          role: "admin"
        )

        Decidim::Assemblies::Admin::CreateAssemblyAdmin.call(
          form,
          user,
          assembly
        )

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
