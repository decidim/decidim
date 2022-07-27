# frozen_string_literal: true

shared_examples "manage participatory process private users examples" do
  let(:other_user) { create :user, organization:, email: "my_email@example.org" }

  let!(:participatory_space_private_user) { create :participatory_space_private_user, user:, privatable_to: participatory_process }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_participatory_processes.edit_participatory_process_path(participatory_process)
    click_link "Private participants"
  end

  it "shows participatory process private user list" do
    within "#private_users table" do
      expect(page).to have_content(participatory_space_private_user.user.email)
    end
  end

  it "creates a new participatory process private users" do
    find(".card-title a.new").click

    within ".new_participatory_space_private_user" do
      fill_in :participatory_space_private_user_name, with: "John Doe"
      fill_in :participatory_space_private_user_email, with: other_user.email

      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")

    within "#private_users table" do
      expect(page).to have_content(other_user.email)
    end
  end

  describe "when import a batch of private users from csv" do
    it "import a batch of participatory space private users" do
      find(".card-title a.import").click

      # The CSV has no headers
      expect(Decidim::Admin::ImportParticipatorySpacePrivateUserCsvJob).to receive(:perform_later).once.ordered.with("my_user@example.org", "My User Name", participatory_process, user)
      expect(Decidim::Admin::ImportParticipatorySpacePrivateUserCsvJob).to receive(:perform_later).once.ordered.with("my_private_user@example.org", "My Private User Name", participatory_process, user)
      dynamically_attach_file(:participatory_space_private_user_csv_import_file, Decidim::Dev.asset("import_participatory_space_private_users.csv"))
      perform_enqueued_jobs { click_button "Upload" }

      expect(page).to have_content("CSV file uploaded successfully")
    end
  end

  describe "when managing different users" do
    before do
      create :participatory_space_private_user, user: other_user, privatable_to: participatory_process
      visit current_path
    end

    it "deletes a assembly_private_user" do
      within find("#private_users tr", text: other_user.email) do
        accept_confirm { click_link "Delete" }
      end

      expect(page).to have_admin_callout("successfully")

      within "#private_users table" do
        expect(page).to have_no_content(other_user.email)
      end
    end

    context "when the user has not accepted the invitation" do
      before do
        form = Decidim::Admin::ParticipatorySpacePrivateUserForm.from_params(
          name: "test",
          email: "test@example.org"
        )

        Decidim::Admin::CreateParticipatorySpacePrivateUser.call(
          form,
          user,
          participatory_process
        )

        visit current_path
      end

      it "resends the invitation to the user" do
        within find("#private_users tr", text: "test@example.org") do
          click_link "Resend invitation"
        end

        expect(page).to have_admin_callout("successfully")
      end
    end
  end
end
