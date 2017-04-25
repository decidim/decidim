# frozen_string_literal: true
RSpec.shared_examples "manage process admins examples" do
  let(:other_user) { create :user, organization: organization, email: "my_email@example.org" }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin.edit_participatory_process_path(participatory_process)
    click_link "Process users"
  end

  it "process admins" do
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

    within ".callout-wrapper" do
      expect(page).to have_content("successfully")
    end

    within "#process_admins table" do
      expect(page).to have_content(other_user.email)
    end
  end

  describe "when managing different users" do
    let!(:user_role2) { create(:participatory_process_user_role, participatory_process: participatory_process, user: other_user) }

    before do
      visit current_path
    end

    it "updates a process admin" do
      within "#process_admins" do
        within find("#process_admins tr", text: other_user.email) do
          page.find('.action-icon--edit').click
        end
      end

      within ".edit_participatory_process_user_roles" do
        select "Administrator", from: :participatory_process_user_role_role

        find("*[type=submit]").click
      end

      within ".callout-wrapper" do
        expect(page).to have_content("successfully")
      end

      within "#process_admins table" do
        expect(page).to have_content("Administrator")
      end
    end

    it "deletes a participatory_process_user_role" do
      within find("#process_admins tr", text: other_user.email) do
        page.find('a.action-icon--remove').click
      end

      accept_alert_dialogue

      within ".callout-wrapper" do
        expect(page).to have_content("successfully")
      end

      within "#process_admins table" do
        expect(page).not_to have_content(other_user.email)
      end
    end
  end
end
