# frozen_string_literal: true

require "spec_helper"

describe "Search proposals" do
  include ActionView::Helpers::SanitizeHelper

  include_context "with a component"
  let(:participatory_process) do
    create(:participatory_process, :published, :with_steps, organization:)
  end
  let(:manifest_name) { "proposals" }
  let!(:searchables) { create_list(:proposal, 3, component:) }
  let!(:term) { strip_tags(translated(searchables.first.title)).split.sample }
  let(:component) { create(:proposal_component, participatory_space: participatory_process) }

  before do
    searchables << create(:proposal, component:, title: "A proposal with a title")
    searchables.each { |s| s.update(published_at: Time.current) }
  end

  include_examples "searchable results"

  context "when rendering the results in the search page" do
    let(:search_term) { "doggo" }
    let(:search_path) { decidim.search_path(term: search_term, filter: { with_resource_type: "Decidim::Proposals::Proposal" }) }
    let(:proposal_taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:, skip_injection: true) }
    let(:child_proposal_taxonomy) { create(:taxonomy, parent: proposal_taxonomy, organization:, skip_injection: true) }
    let!(:proposal_taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: proposal_taxonomy) }
    let!(:child_proposal_taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: child_proposal_taxonomy) }
    let!(:amendable_proposal) do
      create(
        :proposal,
        component:,
        taxonomies: [proposal_taxonomy, child_proposal_taxonomy],
        title: { en: "A doggo proposal to be amended" }
      )
    end
    let!(:emendation_proposal) do
      create(
        :proposal,
        component:,
        taxonomies: [proposal_taxonomy, child_proposal_taxonomy],
        title: { en: "A doggo proposal amending another one" }
      )
    end
    let!(:amendment) { create(:amendment, amendable: amendable_proposal, emendation: emendation_proposal, amender: emendation_proposal.creator_author) }

    before do
      visit search_path
    end

    it "renders the proposal title as a link to the proposal page" do
      [amendable_proposal, emendation_proposal].each do |proposal|
        expect(page).to have_link(translated(proposal.title), href: Decidim::ResourceLocatorPresenter.new(proposal).path)
      end
    end

    it "renders the taxonomies of the proposals" do
      [amendable_proposal, emendation_proposal].each do |proposal|
        within "div.card__search#proposal_#{proposal.id}" do
          expect(page).to have_css(".card__search-metadata", text: translated(proposal_taxonomy.name))
          expect(page).to have_css(".card__search-metadata", text: translated(child_proposal_taxonomy.name))
        end
      end
    end

    it "renders the amendment item for a proposal that amends another one" do
      within "div.card__search#proposal_#{emendation_proposal.id}" do
        expect(page).to have_css(".card__search-metadata", text: "Amendment")
      end
    end

    it "does not render the amendment item for the amended proposal" do
      within "div.card__search#proposal_#{amendable_proposal.id}" do
        expect(page).to have_no_css(".card__search-metadata", text: "Amendment")
      end
    end
  end
end
