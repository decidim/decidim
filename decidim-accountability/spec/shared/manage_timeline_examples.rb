# frozen_string_literal: true

RSpec.shared_examples "manage timeline" do
  let(:attributes) { attributes_for(:timeline_entry, result:) }

  it "updates a timeline entry", versioning: true do
    visit current_path
    click_on "Edit", match: :first

    within ".edit_timeline_entry" do
      fill_in_datepicker :timeline_entry_entry_date_date, with: Date.current.strftime("%d/%m/%Y")
      fill_in_i18n(:timeline_entry_title, "#timeline_entry-title-tabs", **attributes[:title].except("machine_translations"))
      fill_in_i18n_editor(:timeline_entry_description, "#timeline_entry-description-tabs", **attributes[:description].except("machine_translations"))

      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")

    within "table" do
      expect(page).to have_content(translated(attributes[:title]))
    end

    visit decidim_admin.root_path
    expect(page).to have_content("updated the #{translated(attributes[:title])} timeline entry")
  end

  it "creates a timeline entry", versioning: true do
    click_on "New milestone", match: :first

    within ".new_timeline_entry" do
      fill_in_datepicker :timeline_entry_entry_date_date, with: Date.current.strftime("%d/%m/%Y")
      fill_in_i18n(:timeline_entry_title, "#timeline_entry-title-tabs", **attributes[:title].except("machine_translations"))
      fill_in_i18n_editor(:timeline_entry_description, "#timeline_entry-description-tabs", **attributes[:description].except("machine_translations"))

      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")

    within "table" do
      expect(page).to have_content(translated(attributes[:title]))
    end

    visit decidim_admin.root_path
    expect(page).to have_content("created the #{translated(attributes[:title])} timeline entry")
  end
end
