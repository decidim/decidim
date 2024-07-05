# frozen_string_literal: true

shared_context "when inviting process users" do
  let(:participatory_process) { create(:participatory_process) }
  let(:organization) { participatory_process.organization }
  let(:user) { create(:user, :admin, :confirmed, organization: participatory_process.organization) }
  let(:email) { "this_email_does_not_exist@example.org" }

  def invite_user
    login_as user, scope: :user

    visit decidim_admin_participatory_processes.participatory_process_user_roles_path(participatory_process)
    within "[data-content]" do
      click_link "New process admin"
    end

    fill_in "Name", with: "Alice Liddel"
    fill_in "Email", with: email
    select role, from: "Role"
    click_button "Create"
    logout :user
  end

  def edit_user(username)
    login_as user, scope: :user

    visit decidim_admin_participatory_processes.participatory_process_user_roles_path(participatory_process)

    within "tr", text: username do
      click_on "Edit"
    end
  end
end
