# frozen_string_literal: true

require "spec_helper"

describe "Explore results", type: :feature do
  include_context "feature"

  let(:titles) { %w(Biure Atque Delectus Quia Fuga) }
  let(:manifest_name) { "results" }
  let(:results_count) { 5 }
  let!(:scope) { create :scope, organization: organization }
  let!(:results) do
    Array.new(results_count) do |n|
      create(:result, title: { en: titles[n] }, feature: feature)
    end
  end

  context "index" do
    it "shows all results ordered alphabetically" do
      visit_feature

      expect(page).to have_selector(".card--result", count: results_count)

      results.each do |result|
        expect(page).to have_content(translated(result.title))
      end
    end

    context "when filtering" do
      before do
        create(:result, feature: feature, scope: scope)
      end

      context "when the process has a linked scope" do
        before do
          participatory_process.update_attributes(scope: scope)
        end

        it "enables filtering by scope" do
          visit_feature

          within ".filters" do
            expect(page).to have_no_content(/Scopes/i)
          end
        end
      end

      context "when the process has no linked scope" do
        before do
          participatory_process.update_attributes(scope: nil)
        end

        it "enables filtering by scope" do
          visit_feature

          within ".filters" do
            expect(page).to have_content(/Scopes/i)
          end
        end
      end

      context "when filtering by scope" do
        it "lists the filtered results" do
          visit_feature

          within ".filters" do
            select2(translated(scope.name), xpath: '//select[@id="filter_scope_id"]/..', search: true)
          end

          expect(page).to have_css(".card--result", count: 1)
        end
      end
    end

    context "when paginating" do
      before do
        Decidim::Results::Result.destroy_all
      end

      let!(:collection) { create_list :result, collection_size, feature: feature }
      let!(:resource_selector) { ".card--result" }

      it_behaves_like "a paginated resource"
    end
  end

  context "show" do
    let(:path) { resource_locator(result).path }
    let(:results_count) { 1 }
    let(:result) { results.first }

    it "shows all result info" do
      visit path

      expect(page).to have_i18n_content(result.title)
      expect(page).to have_i18n_content(result.description)
      expect(page).to have_content(result.reference)

      within ".section.view-side" do
        expect(page).to have_content(/Proposals/i)
        expect(page).to have_content(/Meetings/i)
        expect(page).to have_content(/Comments/i)
        expect(page).to have_content(/Attendees/i)
        expect(page).to have_content(/Supports/i)
        expect(page).to have_content(/Contributions/i)
      end
    end

    context "without category or scope" do
      it "does not show any tag" do
        visit path

        expect(page).to have_no_selector("ul.tags.tags--result")
      end
    end

    context "with a category" do
      let(:result) do
        result = results.first
        result.category = create :category, participatory_process: participatory_process
        result.save
        result
      end

      it "shows tags for category" do
        visit path

        expect(page).to have_selector("ul.tags.tags--result")
        within "ul.tags.tags--result" do
          expect(page).to have_content(translated(result.category.name))
        end
      end

      it "links to the filter for this category" do
        visit path

        within "ul.tags.tags--result" do
          click_link translated(result.category.name)
        end
        expect(page).to have_select("filter_category_id", selected: translated(result.category.name))
      end
    end

    context "with a scope" do
      let(:result) do
        result = results.first
        result.scope = create :scope, organization: organization
        result.save
        result
      end

      it "shows tags for scope" do
        visit path

        expect(page).to have_selector("ul.tags.tags--result")
        within "ul.tags.tags--result" do
          expect(page).to have_content(translated(result.scope.name))
        end
      end

      it "links to the filter for this scope" do
        visit path

        within "ul.tags.tags--result" do
          click_link translated(result.scope.name)
        end
        expect(page).to have_select("filter_scope_id", selected: translated(result.scope.name))
      end
    end

    context "when a proposal has comments" do
      let(:result) { results.first }
      let(:author) { create(:user, :confirmed, organization: feature.organization) }
      let!(:comments) { create_list(:comment, 3, commentable: result) }

      it "shows the comments" do
        visit path

        comments.each do |comment|
          expect(page).to have_content(comment.body)
        end
      end
    end

    context "with linked proposals" do
      let(:proposal_feature) do
        create(:feature, manifest_name: :proposals, participatory_process: result.feature.participatory_process)
      end
      let(:proposals) { create_list(:proposal, 3, feature: proposal_feature) }

      before do
        result.link_resources(proposals, "included_proposals")
      end

      it "shows related proposals" do
        visit path

        proposals.each do |proposal|
          expect(page).to have_content(proposal.title)
          expect(page).to have_content(proposal.author_name)
          expect(page).to have_content(proposal.votes.size)
        end
      end
    end

    context "with linked proposals" do
      let(:meeting_feature) do
        create(:feature, manifest_name: :meetings, participatory_process: result.feature.participatory_process)
      end
      let(:meetings) { create_list(:meeting, 3, feature: meeting_feature) }

      before do
        result.link_resources(meetings, "meetings_through_proposals")
      end

      it "shows related meetings" do
        visit path

        meetings.each do |meeting|
          expect(page).to have_i18n_content(meeting.title)
          expect(page).to have_i18n_content(meeting.description)
        end
      end
    end
  end
end
