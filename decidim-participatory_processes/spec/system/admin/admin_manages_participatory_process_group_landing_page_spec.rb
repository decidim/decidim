# frozen_string_literal: true

require "spec_helper"

describe "Admin manages participatory process group landing page" do
  include_context "when admin administrating a participatory process with hero content block registered"
  let!(:resource) { create(:participatory_process_group, organization:) }
  let(:scope_name) { :participatory_process_group_homepage }
  let(:edit_landing_page_path) { decidim_admin_participatory_processes.edit_participatory_process_group_landing_page_path(resource) }
  let(:active_content_blocks) do
    Decidim::ContentBlock.for_scope(
      scope_name,
      organization:
    ).where(scoped_resource_id: resource.id)
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  def edit_content_block_path(resource, content_block)
    decidim_admin_participatory_processes.edit_participatory_process_group_landing_page_content_block_path(resource, content_block)
  end

  it_behaves_like "manage landing page examples"

  context "when editing a non-persisted content block" do
    it "creates the content block to the db before editing it" do
      visit edit_landing_page_path

      expect do
        within ".edit_content_blocks" do
          click_on "Add content block"
          within "#add-content-block-dropdown" do
            find("a", text: "Hero image").click
          end
        end
      end.to change(active_content_blocks, :count).by(1)
    end

    it "creates the content block when dragged from inactive to active panel" do
      visit edit_landing_page_path

      expect do
        within ".edit_content_blocks" do
          click_on "Add content block"
          within "#add-content-block-dropdown" do
            find("a", text: "Hero image").click
          end
        end

        first("ul.js-list-available li").drag_to(find("ul.js-list-actives"))
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
        scoped_resource_id: resource.id
      )
    end

    let(:hero_settings) do
      {
        button_url_en: "https://example.org/action",
        button_text_en: "hero text"
      }
    end
    let!(:hero_content_block) do
      create(
        :content_block,
        organization:,
        scope_name:,
        scoped_resource_id: resource.id,
        manifest_name: :hero,
        settings: hero_settings
      )
    end

    it "updates the settings of the content block" do
      visit decidim_admin_participatory_processes.edit_participatory_process_group_landing_page_content_block_path(resource, content_block)

      fill_in(
        :content_block_settings_button_text_en,
        with: "Custom button text!"
      )

      click_on "Update"
      visit decidim_admin_participatory_processes.edit_participatory_process_group_landing_page_content_block_path(resource, content_block)
      expect(page).to have_css("input[value='Custom button text!']")

      content_block.reload

      expect(content_block.settings.to_json).to match(/Custom button text!/)
    end

    it "shows settings of the hero" do
      visit decidim_admin_participatory_processes.edit_participatory_process_group_landing_page_content_block_path(resource, hero_content_block)
      hero_settings.values.each do |value|
        expect(page).to have_css("input[value='#{value}']")
      end
    end
  end
end
