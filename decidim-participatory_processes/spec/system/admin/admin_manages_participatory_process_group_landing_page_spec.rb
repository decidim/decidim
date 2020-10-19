# frozen_string_literal: true

require "spec_helper"

describe "Admin manages participatory process group landing page", type: :system do
  include_context "when admin administrating a participatory process"
  let!(:participatory_process_group) { create(:participatory_process_group, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when editing a participatory process group landing page" do
    it "has sub nav with Landing page active" do
      visit decidim_admin_participatory_processes.edit_participatory_process_group_landing_page_path(participatory_process_group)
      within "div.secondary-nav" do
        expect(page).to have_content("Info")
        expect(page).to have_content("Landing page")
        active_secondary_nav = find(:xpath, ".//li[@class='is-active']")
        expect(active_secondary_nav.text).to eq("Landing page")
      end
    end
  end

  context "when editing a non-persisted content block" do
    it "creates the content block to the db before editing it" do
      visit decidim_admin_participatory_processes.edit_participatory_process_group_landing_page_path(participatory_process_group)

      expect(Decidim::ContentBlock.for_scope(
        :participatory_process_group_homepage,
        organization: organization
      ).where(scoped_resource_id: participatory_process_group.id).count).to eq 0

      within ".js-list-availables" do
        within find("li", text: "Hero image") do
          find("svg.icon--pencil").click
        end
      end

      expect(Decidim::ContentBlock.for_scope(
        :participatory_process_group_homepage,
        organization: organization
      ).where(scoped_resource_id: participatory_process_group.id).count).to eq 1
    end
  end

  context "when editing a persisted content block" do
    let!(:content_block) do
      create(
        :content_block,
        organization: organization,
        manifest_name: :hero,
        scope_name: :participatory_process_group_homepage,
        scoped_resource_id: participatory_process_group.id
      )
    end

    it "updates the settings of the content block" do
      visit decidim_admin_participatory_processes.edit_participatory_process_group_landing_page_content_block_path(participatory_process_group, :hero)

      fill_in(
        :content_block_settings_welcome_text_en,
        with: "Custom welcome text!"
      )

      click_button "Update"
      visit decidim_admin_participatory_processes.edit_participatory_process_group_landing_page_content_block_path(participatory_process_group, :hero)
      expect(page).to have_selector("input[value='Custom welcome text!']")

      content_block.reload

      expect(content_block.settings.to_json).to match(/Custom welcome text!/)
    end
  end
end
