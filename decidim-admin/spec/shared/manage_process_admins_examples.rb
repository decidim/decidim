# frozen_string_literal: true
RSpec.shared_examples "manage process admins examples" do
  let(:other_user) { create :user, organization: organization, email: "my_email@example.org" }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin.edit_participatory_process_path(participatory_process)
    click_link "Process admins"
  end

  it "process admins" do
    within "#process_admins table" do
      expect(page).to have_content(process_admin.email)
    end
  end

  it "creates a new process admin" do

    within "#process_admins form" do
      fill_in :participatory_process_user_role_email, with: other_user.email
      fill_in :participatory_process_user_role_name, with: "John Doe"
      select "admin", from: :participatory_process_user_role_role

      find("*[type=submit]").click
    end

    within ".callout-wrapper" do
      expect(page).to have_content("successfully")
    end

    within "#process_admins table" do
      expect(page).to have_content(other_user.email)
    end
  end

  context "deleting a participatory process step" do
    let!(:user_role2) { create(:participatory_process_user_role, participatory_process: participatory_process, user: other_user) }

    before do
      visit current_path
    end

    it "deletes a participatory_process_step" do
      within find("#process_admins tr", text: other_user.email) do
        click_link "Destroy"
      end

      within ".callout-wrapper" do
        expect(page).to have_content("successfully")
      end

      within "#process_admins table" do
        expect(page).not_to have_content(other_user.email)
      end
    end
  end
end
