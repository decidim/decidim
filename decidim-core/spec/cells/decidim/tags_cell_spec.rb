# frozen_string_literal: true

require "spec_helper"

describe Decidim::TagsCell, type: :cell do
  controller Decidim::PagesController

  let(:organization) { create(:organization) }
  let(:participatory_space) { create(:participatory_process, organization:) }
  let(:component_proposals) { create(:proposal_component, participatory_space:, settings: component_settings) }
  let(:component_meetings) { create(:meeting_component, participatory_space:, settings: component_settings) }
  let(:component_settings) do
    {
      scopes_enabled: true,
      scope_id: parent_scope.id
    }
  end
  let(:parent_scope) { create(:scope, organization:) }
  let(:scope) { create(:scope, organization:, parent: parent_scope) }
  let(:subscope) { create(:scope, organization:, parent: scope) }
  let(:category) { create(:category, participatory_space:) }
  let(:subcategory) { create(:category, participatory_space:, parent: category) }

  let(:proposal_no_tags) { create(:proposal, component: component_proposals) }
  let(:proposal_scoped) { create(:proposal, component: component_proposals, scope:) }
  let(:proposal_subscoped) { create(:proposal, component: component_proposals, scope: subscope) }
  let(:proposal_categorized) { create(:proposal, component: component_proposals, category:) }
  let(:proposal_subcategorized) { create(:proposal, component: component_proposals, category: subcategory) }
  let(:proposal_scoped_categorized) { create(:proposal, component: component_proposals, scope:, category:) }

  let(:meeting_no_tags) { create(:meeting, component: component_meetings) }
  let(:meeting_scoped) { create(:meeting, component: component_meetings, scope:) }
  let(:meeting_subscoped) { create(:meeting, component: component_meetings, scope: subscope) }
  let(:meeting_categorized) { create(:meeting, component: component_meetings, category:) }
  let(:meeting_subcategorized) { create(:meeting, component: component_meetings, category: subcategory) }
  let(:meeting_scoped_categorized) { create(:meeting, component: component_meetings, scope:, category:) }

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

  context "when a resource has scope or subscope" do
    it "renders the scope of a proposal" do
      html = cell("decidim/tags", proposal_scoped, context: { extra_classes: ["tags--proposal"] }).call
      expect(html).to have_css(".tag-container.tags--proposal")
      expect(html).to have_content(translated(scope.name))
    end

    it "renders the correct filtering link" do
      html = cell("decidim/tags", proposal_scoped, context: { extra_classes: ["tags--proposal"] }).call
      path = Decidim::ResourceLocatorPresenter.new(proposal_scoped).index
      query = { filter: { with_any_scope: [scope.id] } }.to_query
      expect(html).to have_css(%(a[href="#{path}?#{query}"]))
    end

    it "renders the subscope of a proposal" do
      html = cell("decidim/tags", proposal_subscoped, context: { extra_classes: ["tags--proposal"] }).call
      expect(html).to have_css(".tag-container.tags--proposal")
      expect(html).to have_content(translated(subscope.name))
    end

    it "renders the scope of a meeting" do
      html = cell("decidim/tags", meeting_scoped, context: { extra_classes: ["tags--meeting"] }).call
      expect(html).to have_css(".tag-container.tags--meeting")
      expect(html).to have_content(translated(scope.name))
    end

    it "renders the subscope of a meeting" do
      html = cell("decidim/tags", meeting_subscoped, context: { extra_classes: ["tags--meeting"] }).call
      expect(html).to have_css(".tag-container.tags--meeting")
      expect(html).to have_content(translated(subscope.name))
    end
  end

  context "when a resource has category or subcategory" do
    it "renders the category of a proposal" do
      html = cell("decidim/tags", proposal_categorized, context: { extra_classes: ["tags--proposal"] }).call
      expect(html).to have_css(".tag-container.tags--proposal")
      expect(html).to have_content(translated(category.name))
    end

    it "sanitizes the category" do
      name = %(Category a<img src=x onerror=alert(8) >"a)
      custom_category = create(:category, participatory_space:, name: { "en" => name })
      proposal_categorized.category = custom_category
      html = cell("decidim/tags", proposal_categorized, context: { extra_classes: ["tags--proposal"] }).call
      expect(html).to have_css(".tag-container.tags--proposal")
      expect(html).to have_content(name)
    end

    it "renders the correct filtering link" do
      html = cell("decidim/tags", proposal_categorized, context: { extra_classes: ["tags--proposal"] }).call
      path = Decidim::ResourceLocatorPresenter.new(proposal_categorized).index
      query = { filter: { with_any_category: [category.id] } }.to_query
      expect(html).to have_css(%(a[href="#{path}?#{query}"]))
    end

    it "renders the subcategory of a proposal" do
      html = cell("decidim/tags", proposal_subcategorized, context: { extra_classes: ["tags--proposal"] }).call
      expect(html).to have_css(".tag-container.tags--proposal")
      expect(html).to have_content(translated(subcategory.name))
    end

    it "renders the category of a meeting" do
      html = cell("decidim/tags", meeting_categorized, context: { extra_classes: ["tags--meeting"] }).call
      expect(html).to have_css(".tag-container.tags--meeting")
      expect(html).to have_content(translated(category.name))
    end

    it "renders the subcategory of a meeting" do
      html = cell("decidim/tags", meeting_subcategorized, context: { extra_classes: ["tags--meeting"] }).call
      expect(html).to have_css(".tag-container.tags--meeting")
      expect(html).to have_content(translated(subcategory.name))
    end
  end

  context "when a resource has scope and category" do
    it "renders the scope and category of a proposal" do
      html = cell("decidim/tags", proposal_scoped_categorized, context: { extra_classes: ["tags--proposal"] }).call
      expect(html).to have_css(".tag-container.tags--proposal")
      expect(html).to have_content(translated(scope.name))
      expect(html).to have_content(translated(category.name))
    end

    it "renders the scope and category of a meeting" do
      html = cell("decidim/tags", meeting_scoped_categorized, context: { extra_classes: ["tags--meeting"] }).call
      expect(html).to have_css(".tag-container.tags--meeting")
      expect(html).to have_content(translated(scope.name))
      expect(html).to have_content(translated(category.name))
    end
  end

  context "when resources has a taxonomies" do
    let(:root_taxonomy) { create(:taxonomy, organization:) }
    let(:taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:) }

    let(:proposal_no_taxonomies) { create(:proposal, component: component_proposals) }
    let(:proposal_taxonomized) { create(:proposal, component: component_proposals, taxonomies: [taxonomy]) }

    it "renders the taxonomy of a proposal" do
      html = cell("decidim/tags", proposal_taxonomized, context: { extra_classes: ["tags--proposal"] }).call
      expect(html).to have_css(".tag-container.tags--proposal")
      expect(html).to have_content(decidim_sanitize_translated(taxonomy.name))
    end

    it "renders the correct filtering link" do
      html = cell("decidim/tags", proposal_taxonomized, context: { extra_classes: ["tags--proposal"] }).call
      path = Decidim::ResourceLocatorPresenter.new(proposal_taxonomized).index
      query = { filter: { "with_any_taxonomies[#{root_taxonomy.id}]" => [taxonomy.id] } }.to_query
      expect(html).to have_css(%(a[href="#{path}?#{query}"]))
    end

    it "does not render the taxonomies of a proposal if not present" do
      html = cell("decidim/tags", proposal_no_taxonomies, context: { extra_classes: ["tags--proposal"] }).call
      expect(html).to have_no_css(".tag-container.tags--proposal")
    end
  end
end
