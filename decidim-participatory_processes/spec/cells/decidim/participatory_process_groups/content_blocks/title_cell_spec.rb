# frozen_string_literal: true

require "spec_helper"

describe Decidim::ParticipatoryProcessGroups::ContentBlocks::TitleCell, type: :cell do
  subject { cell(content_block.cell, content_block).call }

  let(:organization) { create(:organization) }
  let(:hashtag) { "hashtag" }
  let(:group_url) { "https://www.example.org/group" }
  let(:meta_scope) { { en: "Barcelona" } }
  let(:participatory_process_group) do
    create(
      :participatory_process_group,
      organization: organization,
      hashtag: hashtag,
      group_url: group_url,
      meta_scope: meta_scope
    )
  end
  let(:content_block) do
    create(
      :content_block,
      organization: organization,
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

    it "shows the group description " do
      expect(subject).to have_content(
        ActionView::Base.full_sanitizer.sanitize(translated(participatory_process_group.description, locale: :en), tags: [])
      )
    end

    it "shows some meta attributes" do
      expect(subject).to have_selector("svg.icon--twitter")
      expect(subject).to have_link("#hashtag", href: "https://twitter.com/hashtag/hashtag")
      expect(subject).to have_selector("svg.icon--external-link")
      expect(subject).to have_link("www.example.org/group", href: group_url)
      expect(subject).to have_selector("svg.icon--globe")
      expect(subject).to have_content("Barcelona")
    end

    it "shows participatory processes count" do
      expect(subject).to have_content("#{participatory_process_group.participatory_processes.count} processes")
    end

    context "when metadata is not present" do
      let(:hashtag) { nil }
      let(:group_url) { nil }
      let(:meta_scope) { nil }

      it "hides meta attributes containers" do
        expect(subject).to have_no_selector("svg.icon--twitter")
        expect(subject).to have_no_selector("svg.icon--external-link")
        expect(subject).to have_no_selector("svg.icon--globe")
      end
    end
  end
end
