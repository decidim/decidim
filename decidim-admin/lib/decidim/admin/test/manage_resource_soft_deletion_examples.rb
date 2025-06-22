# frozen_string_literal: true

shared_examples "manage soft deletable component or space" do |resource_name|
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

      accept_confirm do
        within("tr", text: title[:en]) do
          # To remove once all the actions are migrated to dropdowns
          find("button[data-component='dropdown']").click if page.has_css?("button[data-component='dropdown']")
          click_on "Soft delete"
        end
      end

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
      within("tr", text: title[:en]) do
        # To remove once all the actions are migrated to dropdowns
        find("button[data-component='dropdown']").click if page.has_css?("button[data-component='dropdown']")
        have_css(".dropdown__button-disabled span", text: "Soft delete")
      end
    end
  end

  context "when the participatory space is trashed" do
    before do
      resource.destroy!
      resource.reload
      visit trash_path
      click_on title[:en]
    end

    it "shows warning message" do
      expect(page).to have_content("You are currently viewing deleted items.")
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
      find("button[data-component='dropdown']").click if page.has_css?("button[data-component='dropdown']")
      accept_confirm { click_on " delete" }
    end

    expect(page).to have_admin_callout("successfully")

    within "table" do
      expect(page).to have_no_content(title[:en])
    end
  end
end

shared_examples "manage trashed resource" do |resource_name|
  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    resource.destroy!
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
      # To remove once all the actions are migrated to dropdowns
      within("tr", text: title[:en]) do
        find("button[data-component='dropdown']").click if page.has_css?("button[data-component='dropdown']")
        click_on "Restore"
      end

      expect(page).to have_admin_callout("successfully")
      visit trash_path
      within "table" do
        expect(page).to have_no_content(title[:en])
      end
    end
  end
end
