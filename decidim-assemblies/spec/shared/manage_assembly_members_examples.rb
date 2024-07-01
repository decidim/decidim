# frozen_string_literal: true

shared_examples "manage assembly members examples" do
  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_assemblies.edit_assembly_path(assembly)
    within_admin_sidebar_menu do
      click_on "Members"
    end
  end

  context "without existing user" do
    let!(:assembly_member) { create(:assembly_member, assembly:) }
    let(:attributes) { attributes_for(:assembly_member, assembly:) }

    it "creates a new assembly member", versioning: true do
      click_on "New assembly member"

      fill_in_datepicker :assembly_member_designation_date_date, with: Time.current.strftime("%d/%m/%Y")

      within ".new_assembly_member" do
        fill_in(:assembly_member_full_name, with: attributes[:full_name])
        fill_in(:assembly_member_gender, with: attributes[:gender])
        fill_in(:assembly_member_birthplace, with: attributes[:birthplace])
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
        expect(page).to have_content(attributes[:full_name])
      end

      visit decidim_admin.root_path
      expect(page).to have_content("created the #{attributes[:full_name]} member")
    end
  end

  context "with existing user" do
    let!(:member_user) { create(:user, :confirmed, organization: assembly.organization) }

    it "creates a new assembly member" do
      click_on "New assembly member"

      fill_in_datepicker :assembly_member_designation_date_date, with: Time.current.strftime("%d/%m/%Y")

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
    let!(:member_organization) { create(:user_group, :confirmed, :verified, organization: assembly.organization) }

    it "creates a new assembly member" do
      click_on "New assembly member"

      fill_in_datepicker :assembly_member_designation_date_date, with: Time.current.strftime("%d/%m/%Y")

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
    let!(:assembly_member) { create(:assembly_member, assembly:) }
    let(:attributes) { attributes_for(:assembly_member, assembly:) }

    before do
      visit current_path
    end

    it "shows assembly members list" do
      within "#assembly_members table" do
        expect(page).to have_content(assembly_member.full_name)
      end
    end

    it "updates an assembly member", versioning: true do
      within "#assembly_members tr", text: assembly_member.full_name do
        click_on "Edit"
      end

      within ".edit_assembly_member" do
        fill_in(:assembly_member_full_name, with: attributes[:full_name])
        fill_in(:assembly_member_gender, with: attributes[:gender])
        fill_in(:assembly_member_birthplace, with: attributes[:birthplace])

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
      expect(page).to have_current_path decidim_admin_assemblies.assembly_members_path(assembly)

      within "#assembly_members table" do
        expect(page).to have_content(attributes[:full_name])
      end

      visit decidim_admin.root_path
      expect(page).to have_content("updated the #{assembly_member.full_name} member")
    end

    it "deletes the assembly member" do
      within "#assembly_members tr", text: assembly_member.full_name do
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
    let!(:collection) { create_list(:assembly_member, collection_size, assembly:) }
    let!(:resource_selector) { "#assembly_members tbody tr" }

    before do
      visit current_path
    end

    it "lists 15 members per page by default" do
      expect(page).to have_css(resource_selector, count: 15)
      expect(page).to have_css("[data-pages] [data-page]", count: 2)
      click_on "Next"
      expect(page).to have_css("[data-pages] [data-page][aria-current='page']", text: "2")
      expect(page).to have_css(resource_selector, count: 5)
    end
  end
end
