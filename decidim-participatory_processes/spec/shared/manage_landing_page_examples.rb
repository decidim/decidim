# frozen_string_literal: true

shared_examples "manage landing page examples" do
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

  context "when editing a participatory process group landing page" do
    it "has breadcrumb with landing page" do
      visit edit_landing_page_path

      within("div.process-title-content-breadcrumb-container-left") do
        expect(page).to have_css("span", text: "Landing page")
      end
    end
  end

  context "when editing a non-persisted content block" do
    it "creates the content block to the db before editing it" do
      visit edit_landing_page_path

      expect do
        within ".edit_content_blocks" do
          click_on(text: "Add content block")
          within "#add-content-block-dropdown" do
            find("a", text: "Hero image and CTA", exact_text: true).click
          end
        end
      end.to change(active_content_blocks, :count).by(1)
    end

    it "creates the content block when dragged from inactive to active panel" do
      visit edit_landing_page_path

      expect do
        within ".edit_content_blocks" do
          click_on(text: "Add content block")
          within "#add-content-block-dropdown" do
            find("a", text: "Hero image and CTA", exact_text: true).click
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
        scope_name:,
        scoped_resource_id: resource.id
      )
    end

    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
    end

    it "updates the settings of the content block" do
      visit edit_content_block_path(resource, content_block)

      fill_in(
        :content_block_settings_button_text_en,
        with: "Custom button text!"
      )

      click_on "Update"
      visit edit_content_block_path(resource, content_block)
      expect(page).to have_css("input[value='Custom button text!']")

      content_block.reload

      expect(content_block.settings.to_json).to match(/Custom button text!/)
    end
  end
end

shared_context "when admin administrating a participatory process with hero content block registered" do
  include_context "when admin administrating a participatory process"

  before do
    unless Decidim.content_blocks.for(scope_name).any? { |cb| cb.name == :hero }
      Decidim.content_blocks.register(scope_name, :hero) do |content_block|
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
          settings.attribute :button_text, type: :text, translated: true
        end

        content_block.default!
      end
    end
  end
end
