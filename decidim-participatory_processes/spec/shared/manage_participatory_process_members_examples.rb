# frozen_string_literal: true

shared_examples "manage participatory process members examples" do
  let(:other_user) { create(:user, organization:, email: "my_email@example.org") }

  let!(:member) { create(:member, user:, privatable_to: participatory_process) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_participatory_processes.edit_participatory_process_path(participatory_process)
    within_admin_sidebar_menu do
      click_on "Members"
    end
  end

  it "shows participatory process member list" do
    within "#members table" do
      expect(page).to have_content(member.user.email)
    end
  end

  it "creates a new participatory process members" do
    click_on "New member"

    within ".new_member" do
      fill_in :member_name, with: "John Doe"
      fill_in :member_email, with: other_user.email

      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")

    within "#members table" do
      expect(page).to have_content(other_user.email)
    end

    visit decidim_admin.root_path
    expect(page).to have_content("invited #{other_user.name} to be a member")
  end

  describe "when import a batch of members from csv" do
    it "import a batch of members" do
      click_on "Import via CSV"

      # The CSV has no headers
      expect(Decidim::Admin::ParticipatorySpace::ImportMemberCsvJob).to receive(:perform_later).once.ordered.with("john.doe@example.org", "John Doe", participatory_process, user)
      expect(Decidim::Admin::ParticipatorySpace::ImportMemberCsvJob).to receive(:perform_later).once.ordered.with("jane.doe@example.org", "Jane Doe", participatory_process, user)
      dynamically_attach_file(:member_csv_import_file, Decidim::Dev.asset("import_members.csv"))
      perform_enqueued_jobs { click_on "Upload" }

      expect(page).to have_content("CSV file uploaded successfully")
    end
  end

  describe "when publishing all members" do
    let!(:member) { create(:member, :unpublished, user:, privatable_to: participatory_process) }

    it "publishes all members" do
      click_on "Publish all"

      sleep(1)
      expect(member.reload).to be_published
    end

    it "displays the correct log message" do
      click_on "Publish all"
      sleep(1)
      visit decidim_admin.root_path
      expect(page).to have_content("published all members of the #{translated(participatory_process.title)} participatory process")
    end
  end

  describe "when managing different users" do
    before do
      create(:member, user: other_user, privatable_to: participatory_process)
      visit current_path
    end

    it "deletes an assembly_member" do
      within "#members tr", text: other_user.email do
        find("button[data-controller='dropdown']").click
        accept_confirm { click_on "Delete" }
      end

      expect(page).to have_admin_callout("successfully")

      within "#members table" do
        expect(page).to have_no_content(other_user.email)
      end
    end

    context "when the user has not accepted the invitation" do
      before do
        form = Decidim::Admin::ParticipatorySpace::MemberForm.from_params(
          name: "test",
          email: "test@example.org"
        )

        Decidim::Admin::ParticipatorySpace::CreateMember.call(
          form,
          participatory_process
        )

        visit current_path
      end

      it "resends the invitation to the user" do
        within "#members tr", text: "test@example.org" do
          find("button[data-controller='dropdown']").click
          click_on "Resend invitation"
        end

        expect(page).to have_admin_callout("successfully")
      end
    end
  end
end
