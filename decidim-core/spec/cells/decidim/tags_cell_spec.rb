# frozen_string_literal: true

require "spec_helper"

describe Decidim::TagsCell, type: :cell do
  controller Decidim::PagesController

  let(:organization) { create(:organization) }
  let(:participatory_space) { create(:participatory_process, organization:) }
  let(:component) { create(:component, participatory_space:) }
  let(:component_proposals) { create(:proposal_component, participatory_space:) }
  let(:component_meetings) { create(:meeting_component, participatory_space:) }

  let(:proposal_no_tags) { create(:proposal, component: component_proposals) }

  let(:meeting_no_tags) { create(:meeting, component: component_meetings) }

  context "when a resource has no tags" do
    it "does not render the tags of a proposal" do
      html = cell("decidim/tags", proposal_no_tags, context: { extra_classes: ["tags--proposal"] }).call
      expect(html).to have_no_css(".tag-container.tags--proposal")
    end

    it "does not render the tags of a meeting" do
      html = cell("decidim/tags", meeting_no_tags, context: { extra_classes: ["tags--meeting"] }).call
      expect(html).to have_no_css(".tag-container.tags--meeting")
    end
  end

  context "when resources has a taxonomies" do
    let(:root_taxonomy) { create(:taxonomy, organization:) }
    let(:taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:) }
    let(:sub_taxonomy) { create(:taxonomy, parent: taxonomy, organization:) }

    let(:resource_no_taxonomies) { create(:dummy_resource, component:) }
    let(:resource_taxonomies) { create(:dummy_resource, component:, taxonomies: [taxonomy]) }
    let(:resource_sub_taxonomies) { create(:dummy_resource, component:, taxonomies: [sub_taxonomy]) }

    it "renders the taxonomy of a resource" do
      html = cell("decidim/tags", resource_taxonomies, context: { extra_classes: ["tags--resource"] }).call
      expect(html).to have_css(".tag-container.tags--resource")
      expect(html).to have_content(decidim_sanitize_translated(taxonomy.name))
    end

    it "renders the sub taxonomy of a resource" do
      html = cell("decidim/tags", resource_sub_taxonomies, context: { extra_classes: ["tags--resource"] }).call
      expect(html).to have_css(".tag-container.tags--resource")
      expect(html).to have_content(decidim_sanitize_translated(sub_taxonomy.name))
    end

    it "renders the correct filtering link" do
      html = cell("decidim/tags", resource_taxonomies, context: { extra_classes: ["tags--resource"] }).call
      path = Decidim::ResourceLocatorPresenter.new(resource_taxonomies).index
      query = { filter: { :with_any_taxonomies => [root_taxonomy.id, taxonomy.id] } }.to_query
      expect(html).to have_css(%(a[href="#{path}?#{query}"]))
    end

    it "does not render the taxonomies of a resource if not present" do
      html = cell("decidim/tags", resource_no_taxonomies, context: { extra_classes: ["tags--resource"] }).call
      expect(html).to have_no_css(".tag-container.tags--resource")
    end
  end
end
