# frozen_string_literal: true

require "spec_helper"

describe "Admin manages participatory process group landing page", type: :system do
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

  def edit_content_block_path(resource, content_block)
    decidim_admin_participatory_processes.edit_participatory_process_group_landing_page_content_block_path(resource, content_block)
  end

  it_behaves_like "manage landing page examples"

  context "when editing a persisted cta content block" do
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
        scope_name:,
        scoped_resource_id: resource.id,
        manifest_name: :cta,
        settings: cta_settings
      )
    end

    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
    end

    it "shows settings of cta" do
      visit edit_content_block_path(resource, cta_content_block)
      cta_settings.values.each do |value|
        expect(page).to have_selector("input[value='#{value}']")
      end
    end
  end
end
