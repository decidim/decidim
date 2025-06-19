# frozen_string_literal: true

RSpec.shared_examples "manage milestone" do
  let(:attributes) { attributes_for(:milestone, result:) }

  it "updates a milestone", versioning: true do
    visit current_path
    click_on "Edit", match: :first

    within ".edit_milestone_entry" do
      fill_in_datepicker :milestone_entry_entry_date_date, with: Date.current.strftime("%d/%m/%Y")
      fill_in_i18n(:milestone_entry_title, "#milestone_entry-title-tabs", **attributes[:title].except("machine_translations"))
      fill_in_i18n_editor(:milestone_entry_description, "#milestone_entry-description-tabs", **attributes[:description].except("machine_translations"))

      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")

    within "table" do
      expect(page).to have_content(translated(attributes[:title]))
    end

    visit decidim_admin.root_path
    expect(page).to have_content("updated the #{translated(attributes[:title])} milestone")
  end

  it "creates a milestone", versioning: true do
    click_on "New milestone", match: :first

    within ".new_milestone_entry" do
      fill_in_datepicker :milestone_entry_entry_date_date, with: Date.current.strftime("%d/%m/%Y")
      fill_in_i18n(:milestone_entry_title, "#milestone_entry-title-tabs", **attributes[:title].except("machine_translations"))
      fill_in_i18n_editor(:milestone_entry_description, "#milestone_entry-description-tabs", **attributes[:description].except("machine_translations"))

      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")

    within "table" do
      expect(page).to have_content(translated(attributes[:title]))
    end

    visit decidim_admin.root_path
    expect(page).to have_content("created the #{translated(attributes[:title])} milestone")
  end
end
