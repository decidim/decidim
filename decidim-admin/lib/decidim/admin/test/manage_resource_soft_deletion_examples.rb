# frozen_string_literal: true

shared_examples "manage soft deletable component or space" do |resource_name|
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
      expect(page).to have_css("td a", text: translated(title))

      accept_confirm { click_on "Soft delete" }

      expect(page).to have_content("successfully")
      expect(page).to have_no_css("td a", text: translated(title))
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
end

shared_examples "manage soft deletable resource" do |resource_name|
  let(:deleted_at) { nil }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit admin_resource_path
  end

  it "moves the #{resource_name} to the trash and displays success message" do
    expect(page).to have_css("td a", text: translated(title))

    accept_confirm { click_on "Soft delete" }

    expect(page).to have_content("successfully")
    expect(page).to have_no_css("td a", text: translated(title))
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

    it "displays the #{resource_name} in the trash" do
      expect(page).to have_css("td a", text: translated(title))
    end

    it "restores the #{resource_name} from the trash" do
      click_on "Restore"

      expect(page).to have_content("successfully restored")
      visit trash_path
      expect(page).to have_no_css("td a", text: translated(title))
    end
  end
end
