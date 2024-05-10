# frozen_string_literal: true

require "spec_helper"

describe "Admin views admin logs" do
  let(:manifest_name) { "sortitions" }
  let(:attributes) { attributes_for(:sortition, component: current_component) }
  let!(:proposal_component) { create(:proposal_component, :published, participatory_space: current_component.participatory_space) }
  let!(:proposal) { create(:proposal, component: proposal_component) }
  let!(:sortition) { create(:sortition, component: current_component) }

  include_context "when managing a component as an admin"

  it "shows the sortition details", versioning: true do
    click_on "New sortition"

    within ".new_sortition" do
      fill_in :sortition_dice, with: Faker::Number.between(from: 1, to: 6)
      fill_in :sortition_target_items, with: Faker::Number.between(from: 1, to: 10)
      select translated(proposal_component.name), from: :sortition_decidim_proposals_component_id
      fill_in_i18n_editor(:sortition_witnesses, "#sortition-witnesses-tabs", **attributes[:witnesses].except("machine_translations"))
      fill_in_i18n_editor(:sortition_additional_info, "#sortition-additional_info-tabs", **attributes[:additional_info].except("machine_translations"))
      fill_in_i18n(:sortition_title, "#sortition-title-tabs", **attributes[:title].except("machine_translations"))

      accept_confirm { find("*[type=submit]").click }
    end

    expect(page).to have_admin_callout("successfully")
    visit decidim_admin.root_path
    expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
  end

  it "Redirects to sortitions view", versioning: true do
    visit_component_admin
    click_on "Edit"

    within ".edit_sortition" do
      fill_in_i18n_editor(
        :sortition_additional_info,
        "#sortition-additional_info-tabs",
        **attributes[:additional_info].except("machine_translations")
      )

      fill_in_i18n(
        :sortition_title,
        "#sortition-title-tabs",
        **attributes[:title].except("machine_translations")
      )

      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")
    visit decidim_admin.root_path
    expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
  end
end
