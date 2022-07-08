# frozen_string_literal: true

shared_examples "manage assembly members examples" do
  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_assemblies.edit_assembly_path(assembly)
    click_link "Members"
  end

  context "without existing user" do
    let!(:assembly_member) { create(:assembly_member, assembly: assembly) }

    it "creates a new assembly member" do
      find(".card-title a.new").click

      execute_script("$('#assembly_member_designation_date').focus()")
      find(".datepicker-days .active").click

      within ".new_assembly_member" do
        fill_in(
          :assembly_member_full_name,
          with: "Daisy O'connor"
        )
      end

      dynamically_attach_file(:assembly_member_non_user_avatar, Decidim::Dev.asset("avatar.jpg")) do
        expect(page).to have_content("You should get the consent of the persons before publishing them as a member")
      end

      within ".new_assembly_member" do
        select "President", from: :assembly_member_position

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
      expect(page).to have_current_path decidim_admin_assemblies.assembly_members_path(assembly)

      within "#assembly_members table" do
        expect(page).to have_content("Daisy O'connor")
      end
    end
  end

  context "with existing user" do
    let!(:member_user) { create :user, organization: assembly.organization }

    it "creates a new assembly member" do
      find(".card-title a.new").click

      execute_script("$('#assembly_member_designation_date').focus()")
      find(".datepicker-days .active").click

      within ".new_assembly_member" do
        select "Existing participant", from: :assembly_member_existing_user
        autocomplete_select "#{member_user.name} (@#{member_user.nickname})", from: :user_id

        select "President", from: :assembly_member_position

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
      expect(page).to have_current_path decidim_admin_assemblies.assembly_members_path(assembly)

      within "#assembly_members table" do
        expect(page).to have_content("#{member_user.name} (@#{member_user.nickname})")
      end
    end
  end

  context "with existing user group" do
    let!(:member_organization) { create :user_group, :verified, organization: assembly.organization }

    it "creates a new assembly member" do
      find(".card-title a.new").click

      execute_script("$('#assembly_member_designation_date').focus()")
      find(".datepicker-days .active").click

      within ".new_assembly_member" do
        select "Existing participant", from: :assembly_member_existing_user
        autocomplete_select "#{member_organization.name} (@#{member_organization.nickname})", from: :user_id

        select "President", from: :assembly_member_position

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
      expect(page).to have_current_path decidim_admin_assemblies.assembly_members_path(assembly)

      within "#assembly_members table" do
        expect(page).to have_content("#{member_organization.name} (@#{member_organization.nickname})")
      end
    end
  end

  describe "when managing other assembly members" do
    let!(:assembly_member) { create(:assembly_member, assembly: assembly) }

    before do
      visit current_path
    end

    it "shows assembly members list" do
      within "#assembly_members table" do
        expect(page).to have_content(assembly_member.full_name)
      end
    end

    it "updates an assembly member" do
      within find("#assembly_members tr", text: assembly_member.full_name) do
        click_link "Edit"
      end

      within ".edit_assembly_member" do
        fill_in(
          :assembly_member_full_name,
          with: "Alicia O'connor"
        )

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
      expect(page).to have_current_path decidim_admin_assemblies.assembly_members_path(assembly)

      within "#assembly_members table" do
        expect(page).to have_content("Alicia O'connor")
      end
    end

    it "deletes the assembly member" do
      within find("#assembly_members tr", text: assembly_member.full_name) do
        accept_confirm { find("a.action-icon--remove").click }
      end

      expect(page).to have_admin_callout("successfully")

      within "#assembly_members table" do
        expect(page).to have_no_content(assembly_member.full_name)
      end
    end
  end

  context "when paginating" do
    let!(:collection_size) { 20 }
    let!(:collection) { create_list(:assembly_member, collection_size, assembly: assembly) }
    let!(:resource_selector) { "#assembly_members tbody tr" }

    before do
      visit current_path
    end

    it "lists 15 members per page by default" do
      expect(page).to have_css(resource_selector, count: 15)
      expect(page).to have_css("[data-pages] [data-page]", count: 2)
      click_link "Next"
      expect(page).to have_selector("[data-pages] [data-page][aria-current='page']", text: "2")
      expect(page).to have_css(resource_selector, count: 5)
    end
  end
end
