# frozen_string_literal: true

shared_examples "manage assembly members examples" do
  let(:other_user) { create(:user, organization:, email: "my_email@example.org") }

  let!(:assembly_member) { create(:assembly_member, user:, privatable_to: assembly) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_assemblies.edit_assembly_path(assembly)
    within_admin_sidebar_menu do
      click_on "Members"
    end
  end

  it "shows assembly member list" do
    within "#members table" do
      expect(page).to have_content(assembly_member.user.email)
    end
  end

  it "creates a new assembly members" do
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
      expect(Decidim::Admin::ParticipatorySpace::ImportMemberCsvJob).to receive(:perform_later).once.ordered.with("john.doe@example.org", "John Doe", assembly, user)
      expect(Decidim::Admin::ParticipatorySpace::ImportMemberCsvJob).to receive(:perform_later).once.ordered.with("jane.doe@example.org", "Jane Doe", assembly, user)
      dynamically_attach_file(:member_csv_import_file, Decidim::Dev.asset("import_members.csv"))
      perform_enqueued_jobs { click_on "Upload" }

      expect(page).to have_content("CSV file uploaded successfully")
    end
  end

  describe "when managing different users" do
    before do
      create(:assembly_member, user: other_user, privatable_to: assembly)
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
          assembly
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
