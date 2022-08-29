# frozen_string_literal: true

require "spec_helper"

describe "Admin manages participatory process group landing page", type: :system do
  include_context "when admin administrating a participatory process"
  let!(:participatory_process_group) { create(:participatory_process_group, organization:) }
  let(:active_content_blocks) do
    Decidim::ContentBlock.for_scope(
      :participatory_process_group_homepage,
      organization:
    ).where(scoped_resource_id: participatory_process_group.id)
  end

  before do
    unless Decidim.content_blocks.for(:participatory_process_group_homepage).any? { |cb| cb.name == :hero }
      Decidim.content_blocks.register(:participatory_process_group_homepage, :hero) do |content_block|
        content_block.cell = "decidim/content_blocks/hero"
        content_block.settings_form_cell = "decidim/content_blocks/hero_settings_form"
        content_block.public_name_key = "decidim.content_blocks.hero.name"

        content_block.images = [
          {
            name: :background_image,
            uploader: "Decidim::HomepageImageUploader"
          }
        ]

        content_block.settings do |settings|
          settings.attribute :welcome_text, type: :text, translated: true
        end

        content_block.default!
      end
    end

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

      expect do
        within ".js-list-availables" do
          within find("li", text: "Hero image") do
            find("svg.icon--pencil").click
          end
        end
      end.to change(active_content_blocks, :count).by(1)
    end

    it "creates the content block when dragged from inactive to active panel" do
      visit decidim_admin_participatory_processes.edit_participatory_process_group_landing_page_path(participatory_process_group)
      content_block = first("ul.js-list-availables li")
      active_blocks_list = find("ul.js-list-actives")

      expect do
        content_block.drag_to(active_blocks_list)
        sleep(2)
      end.to change(active_content_blocks, :count).by(1)
    end
  end

  context "when editing a persisted content block" do
    let!(:content_block) do
      create(
        :content_block,
        organization:,
        manifest_name: :hero,
        scope_name: :participatory_process_group_homepage,
        scoped_resource_id: participatory_process_group.id
      )
    end
    let(:cta_settings) do
      {
        button_url: "https://example.org/action",
        button_text_en: "cta text",
        description_en: "cta description"
      }
    end
    let!(:cta_content_block) do
      create(
        :content_block,
        organization:,
        scope_name: :participatory_process_group_homepage,
        scoped_resource_id: participatory_process_group.id,
        manifest_name: :cta,
        settings: cta_settings
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

    it "shows settings of cta" do
      visit decidim_admin_participatory_processes.edit_participatory_process_group_landing_page_content_block_path(participatory_process_group, :cta)
      cta_settings.values.each do |value|
        expect(page).to have_selector("input[value='#{value}']")
      end
    end
  end
end
