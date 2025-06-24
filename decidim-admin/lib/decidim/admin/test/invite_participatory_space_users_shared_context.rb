# frozen_string_literal: true

shared_context "when inviting participatory space users" do
  let(:organization) { participatory_space.organization }
  let(:user) { create(:user, :admin, :confirmed, organization: participatory_space.organization) }
  let(:email) { "this_email_does_not_exist@example.org" }
  let(:role) { "Moderator" }

  def invite_user
    login_as user, scope: :user

    visit participatory_space_user_roles_path
    within "[data-content]" do
      click_on new_button_label
    end

    fill_in "Name", with: "Alice Liddel"
    fill_in "Email", with: email
    select role, from: "Role"
    click_on "Create"
    expect(page).to have_content("successfully added")
    logout :user
  end

  def edit_user(username)
    login_as user, scope: :user

    visit participatory_space_user_roles_path

    within "tr", text: username do
      find("button[data-component='dropdown']").click
      click_on "Edit"
    end
  end
end
