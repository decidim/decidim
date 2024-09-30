# frozen_string_literal: true

shared_examples "manage soft deletable component" do |resource_name|
  let(:deleted_at) { nil }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when the participatory space is unpublished" do
    before do
      resource.unpublish!
      resource.reload
      visit admin_resource_path
    end

    it "moves the #{resource_name} to the trash and displays success message" do
      within "table" do
        expect(page).to have_content(title[:en])
      end

      accept_confirm { click_on "Soft delete" }

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).to have_no_content(title[:en])
      end
    end
  end

  context "when the participatory space is published" do
    before do
      visit admin_resource_path
    end

    it "does not allow to move it to the trash" do
      expect(page).to have_no_content("Soft delete")
    end
  end

  context "when the participatory space is trashed" do
    before do
      resource.trash!
      resource.reload
      visit trash_path
      click_on title[:en]
    end

    it "shows warning message" do
      expect(page).to have_content("You are currently viewing deleted items.")
    end
  end
end

shared_examples "manage soft deletable participatory space" do |resource_name|
  let(:deleted_at) { nil }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit participatory_space_trash_path
  end

  context "when the participatory space is published" do
    it "does not allow to move it to the trash" do
      within "table" do
        expect(page).to have_no_content("Soft delete")
      end
    end
  end

  context "when the participatory space is not published" do
    before do
      participatory_process.unpublish!
      participatory_process.reload
      visit decidim_admin_participatory_processes.participatory_processes_path
    end

    it "moves the #{resource_name} to the trash and displays success message" do
      within "table" do
        expect(page).to have_content(participatory_space_title)
        accept_confirm { click_on "Soft delete" }
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).to have_no_content(participatory_space_title)
      end
    end
  end

  context "when the participatory space is trashed" do
    before do
      participatory_process.trash!
      participatory_process.reload
      visit participatory_space_trash_path
    end

    it "shows warning message" do
      expect(page).to have_content("You are currently viewing deleted items.")
    end

    context "when editing the participatory space" do
      before do
        within "table" do
          click_on participatory_space_title
        end
      end

      it "shows warning message" do
        expect(page).to have_content("You are currently viewing deleted items.")
      end
    end
  end
end

shared_examples "manage soft deletable resource" do |resource_name|
  let(:deleted_at) { nil }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit admin_resource_path
  end

  it "moves the #{resource_name} to the trash and displays success message" do
    resource_row = "tr[data-id='#{resource.id}']"

    expect(page).to have_content(title[:en])

    within(resource_row) do
      accept_confirm { click_on "Soft delete" }
    end

    expect(page).to have_admin_callout("successfully")

    within "table" do
      expect(page).to have_no_content(title[:en])
    end
  end
end

shared_examples "manage trashed resource" do |resource_name|
  let(:deleted_at) { Time.current }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when the #{resource_name} is trashed" do
    before do
      visit trash_path
    end

    it "shows page title" do
      expect(page).to have_content("Deleted #{resource_name.pluralize}")
    end

    it "displays the #{resource_name} in the trash" do
      within "table" do
        expect(page).to have_content(title[:en])
      end
    end

    it "restores the #{resource_name} from the trash" do
      click_on "Restore"

      expect(page).to have_admin_callout("successfully")
      visit trash_path
      within "table" do
        expect(page).to have_no_content(title[:en])
      end
    end
  end
end
