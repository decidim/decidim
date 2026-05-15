# frozen_string_literal: true

require "spec_helper"

describe Decidim::ParticipatoryProcessGroups::ContentBlocks::MainDataCell, type: :cell do
  subject { cell(content_block.cell, content_block).call }

  let(:organization) { create(:organization) }
  let(:group_url) { "https://www.example.org/group" }
  let(:meta_scope) { { en: "Barcelona" } }
  let(:participatory_process_group) do
    create(
      :participatory_process_group,
      organization:,
      group_url:,
      meta_scope:
    )
  end
  let(:content_block) do
    create(
      :content_block,
      organization:,
      manifest_name: :title,
      scope_name: :participatory_process_group_homepage,
      scoped_resource_id: participatory_process_group.id
    )
  end

  controller Decidim::ParticipatoryProcesses::ParticipatoryProcessGroupsController

  before do
    allow(controller).to receive(:group).and_return(participatory_process_group)
  end

  context "when the content block is called with a participatory process group" do
    it "shows the group title" do
      expect(subject).to have_content(translated(participatory_process_group.title, locale: :en))
    end

    it "shows the group description" do
      expect(subject).to have_content(
        ActionView::Base.full_sanitizer.sanitize(translated(participatory_process_group.description, locale: :en), tags: [])
      )
    end
  end
end
