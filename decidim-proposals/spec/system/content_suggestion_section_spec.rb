# frozen_string_literal: true

require "spec_helper"

describe "ContentSuggestionSection" do
  include_context "with a component"
  let(:manifest_name) { "proposals" }
  let(:organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, organization:) }
  let!(:user) { create(:user, :confirmed, organization: participatory_process.organization) }

  let(:address) { "Carrer de Sant Joan, 123, 08001 Barcelona" }
  let(:latitude) { 41.38879 }
  let(:longitude) { 2.15899 }

  let(:proposal) { create(:proposal, component:, users: [user], address:, latitude:, longitude:, taxonomies: [taxonomy, sub_taxonomy]) }

  let!(:taxonomy) { create(:taxonomy, :with_parent, skip_injection: true, organization:) }
  let!(:sub_taxonomy) { create(:taxonomy, parent: taxonomy, organization:) }
  let(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy: taxonomy.parent) }
  let!(:taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: taxonomy) }
  let!(:taxonomy_filter_ids) { [taxonomy_filter.id] }

  let!(:most_recent_proposal) { create(:proposal, :accepted, component:, users: [user], created_at: 1.minute.ago, comments_count: 2, endorsements_count: 2) }
  let!(:nearest_proposal) { create(:proposal, :accepted, component:,  users: [user], created_at: 2.weeks.ago, latitude:, longitude:) }
  let!(:taxonomy_proposal) { create(:proposal, :accepted, component:, users: [user], created_at: 2.weeks.ago, taxonomies: [taxonomy, sub_taxonomy]) }

  let!(:proposals_list) do
    create_list(
      :proposal,
      15,
      :accepted,
      component:,
      created_at: 1.hour.ago
    )
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when Content Suggestions are disabled" do
    let(:component) do
      create(:component, manifest_name:, participatory_space: participatory_process, settings: {
               content_suggestions_enabled: false,
               content_suggestions_limit: 5,
               content_suggestions_criteria: "random"
             })
    end

    it "does not have has content-suggestions-list div" do
      visit resource_locator(proposal).path
      expect(page).to have_no_css(".content-suggestions-list")
    end
  end

  context "when Content Suggestions are enabled" do
    let(:component) do
      create(:component, manifest_name:, participatory_space: participatory_process, settings: {
               content_suggestions_enabled: true,
               content_suggestions_limit: 5,
               content_suggestions_criteria: "random"
             })
    end

    it "has content-suggestions-list div" do
      visit resource_locator(proposal).path
      expect(page).to have_css(".content-suggestions-list")
    end

    it "has 5 cards" do
      visit resource_locator(proposal).path
      within ".content-suggestions-list" do
        expect(all(".card__list").count).to eq(5)
      end
    end
  end

  context "when content_suggestions_criteria is most recent" do
    let(:component) do
      create(:component, manifest_name:, participatory_space: participatory_process, settings: {
               content_suggestions_enabled: true,
               content_suggestions_limit: 3,
               content_suggestions_criteria: "most_recent",
               endorsements_enabled: true
             })
    end

    it "has most recent proposal at the top" do
      visit resource_locator(proposal).path
      within ".content-suggestions-list" do
        within first(".card__list") do
          expect(page).to have_css("#proposals__proposal_#{most_recent_proposal.id}")
        end
      end
    end

    it "displays the correct proposal info on cards" do
      visit resource_locator(proposal).path
      within ".content-suggestions-list" do
        within first(".card__list-content") do
          expect(page).to have_css(".card__list-title")
          expect(page).to have_content(most_recent_proposal.title["en"])

          within ".card__list-metadata" do
            expect(page).to have_css("[data-comments-count]", text: 2)
            expect(page).to have_css("[data-endorsements-count]", text: 2)
          end
        end
      end
    end
  end

  context "when content_suggestions_criteria is location" do
    let(:component) do
      create(:component, manifest_name:, participatory_space: participatory_process, settings: {
               content_suggestions_enabled: true,
               content_suggestions_limit: 3,
               content_suggestions_criteria: "location"
             })
    end

    it "has nearest proposal at the top" do
      visit resource_locator(proposal).path
      within ".content-suggestions-list" do
        within first(".card__list") do
          expect(page).to have_css("#proposals__proposal_#{nearest_proposal.id}")
        end
      end
    end
  end

  context "when content_suggestions_criteria is taxonomy" do
    let(:component) do
      create(:component, manifest_name:, participatory_space: participatory_process, settings: {
               taxonomy_filters: taxonomy_filter_ids,
               content_suggestions_enabled: true,
               content_suggestions_limit: 3,
               content_suggestions_criteria: "taxonomy"
             })
    end

    it "has the proposal with the same taxonomy at the top" do
      visit resource_locator(proposal).path
      within ".content-suggestions-list" do
        within first(".card__list") do
          expect(page).to have_css("#proposals__proposal_#{taxonomy_proposal.id}")
        end
      end
    end
  end

  context "when limit is above 10" do
    let(:component) do
      create(:component, manifest_name:, participatory_space: participatory_process, settings: {
               content_suggestions_enabled: true,
               content_suggestions_limit: 11,
               content_suggestions_criteria: "random"
             })
    end

    it "displays the max (10) number of proposals" do
      visit resource_locator(proposal).path
      within ".content-suggestions-list" do
        expect(all(".card__list").count).to eq(10)
      end
    end
  end

  context "when limit is negative" do
    let(:component) do
      create(:component, manifest_name:, participatory_space: participatory_process, settings: {
               content_suggestions_enabled: true,
               content_suggestions_limit: -5,
               content_suggestions_criteria: "random"
             })
    end

    it "displays the default number of proposals" do
      visit resource_locator(proposal).path
      within ".content-suggestions-list" do
        expect(all(".card__list").count).to eq(3)
      end
    end
  end
end
