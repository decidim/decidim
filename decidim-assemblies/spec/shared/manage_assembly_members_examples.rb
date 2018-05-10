# frozen_string_literal: true

shared_examples "manage assembly members examples" do
  let!(:assembly_member) { create(:assembly_member, assembly: assembly) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_assemblies.edit_assembly_path(assembly)
    click_link "Members"
  end

  it "shows assembly members list" do
    within "#assembly_members table" do
      expect(page).to have_content(assembly_member.full_name)
    end
  end

  it "creates a new assembly member" do
    find(".card-title a.new").click

    execute_script("$('#date_field_assembly_member_designation_date').focus()")
    find(".datepicker-days .active").click

    within ".new_assembly_member" do
      fill_in(
        :assembly_member_full_name,
        with: "Daisy O'connor"
      )

      select "President", from: :assembly_member_position

      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")
    expect(page).to have_current_path decidim_admin_assemblies.assembly_members_path(assembly)

    within "#assembly_members table" do
      expect(page).to have_content("Daisy O'connor")
    end
  end

  describe "when managing other assembly members" do
    before do
      visit current_path
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

    it "deletes a assembly_member" do
      within find("#assembly_members tr", text: assembly_member.full_name) do
        accept_confirm { find("a.action-icon--remove").click }
      end

      expect(page).to have_admin_callout("successfully")

      within "#assembly_members table" do
        expect(page).to have_no_content(assembly_member.full_name)
      end
    end
  end
end
