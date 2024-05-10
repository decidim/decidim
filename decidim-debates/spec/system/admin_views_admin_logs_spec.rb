# frozen_string_literal: true

require "spec_helper"

describe "Admin views admin logs" do
  let(:manifest_name) { "debates" }
  let!(:debate) { create(:debate, category:, component: current_component) }
  let(:attributes) { attributes_for(:debate, :closed, component: current_component) }

  include_context "when managing a component as an admin"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit_component_admin
  end

  it "updates a debate", versioning: true do
    within "tr", text: translated(debate.title) do
      page.find(".action-icon--edit").click
    end

    within ".edit_debate" do
      fill_in_i18n(:debate_title, "#debate-title-tabs", **attributes[:title].except("machine_translations"))
      fill_in_i18n_editor(:debate_description, "#debate-description-tabs", **attributes[:description].except("machine_translations"))
      fill_in_i18n_editor(:debate_instructions, "#debate-instructions-tabs", **attributes[:instructions].except("machine_translations"))

      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")

    visit decidim_admin.root_path
    expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
  end

  it "creates a new open debate", versioning: true do
    click_on "New debate"

    within ".new_debate" do
      fill_in_i18n(:debate_title, "#debate-title-tabs", **attributes[:title].except("machine_translations"))
      fill_in_i18n_editor(:debate_description, "#debate-description-tabs", **attributes[:description].except("machine_translations"))
      fill_in_i18n_editor(:debate_instructions, "#debate-instructions-tabs", **attributes[:instructions].except("machine_translations"))

      choose "Open"
    end

    expect(page).to have_no_selector "#debate_start_time"
    expect(page).to have_no_selector "#debate_end_time"

    within ".new_debate" do
      select translated(category.name), from: :debate_decidim_category_id

      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")

    visit decidim_admin.root_path
    expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
  end

  it "closes a debate", versioning: true do
    within "tr", text: translated(debate.title) do
      page.find(".action-icon--close").click
    end

    within ".edit_close_debate" do
      fill_in_i18n_editor(:debate_conclusions, "#debate-conclusions-tabs", **attributes[:conclusions].except("machine_translations"))

      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")

    visit decidim_admin.root_path
    expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
  end
end
