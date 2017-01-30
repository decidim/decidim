require "spec_helper"

describe "Explore results", type: :feature do
  include_context "feature"
  let(:manifest_name) { "results" }

  let(:organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, organization: organization) }
  let(:current_feature) { create :feature, participatory_process: participatory_process, manifest_name: :results }
  let(:results_count) { 5 }
  let!(:scope) { create :scope, organization: organization }
  let!(:results) do
    create_list(
      :result,
      results_count,
      feature: current_feature
    )
  end

  before do
    switch_to_host(organization.host)
    visit path
  end

  context "index" do
    let(:path) { decidim_results.results_path(participatory_process_id: participatory_process.id, feature_id: current_feature.id) }

    it "shows all results for the given process" do
      expect(page).to have_selector("article.card", count: results_count)

      results.each do |result|
        expect(page).to have_content(translated result.title)
      end
    end
  end

  context "show" do
    let(:path) { decidim_results.result_path(id: result.id, participatory_process_id: participatory_process.id, feature_id: current_feature.id) }
    let(:results_count) { 1 }
    let(:result) { results.first }

    it "shows all result info" do
      expect(page).to have_i18n_content(result.title)
      expect(page).to have_i18n_content(result.description)
      expect(page).to have_i18n_content(result.short_description)

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
        expect(page).not_to have_selector("ul.tags.tags--result")
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
        expect(page).to have_selector("ul.tags.tags--result")
        within "ul.tags.tags--result" do
          expect(page).to have_content(translated(result.category.name))
        end
      end

      it "links to the filter for this category" do
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
        expect(page).to have_selector("ul.tags.tags--result")
        within "ul.tags.tags--result" do
          expect(page).to have_content(result.scope.name)
        end
      end

      it "links to the filter for this scope" do
        within "ul.tags.tags--result" do
          click_link result.scope.name
        end
        expect(page).to have_checked_field(result.scope.name)
      end
    end

    context "when a proposal has comments" do
      let(:result) { results.first }
      let(:author) { create(:user, :confirmed, organization: feature.organization)}
      let!(:comments) { create_list(:comment, 3, commentable: result) }

      before do
        visit current_path
      end

      it "shows the comments" do
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
        visit current_path
      end

      it "shows related proposals" do
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
        visit current_path
      end

      it "shows related meetings" do
        meetings.each do |meeting|
          expect(page).to have_i18n_content(meeting.title)
          expect(page).to have_i18n_content(meeting.short_description)
        end
      end
    end

    context "when filtering" do
      before do
        create(:result, feature: feature, scope: scope)
        visit_feature
      end

      context "by origin 'official'" do
        it "lists the filtered results" do
          within ".filters" do
            check scope.name
          end

          expect(page).to have_css(".card--result", count: 1)
        end
      end

      context "by origin 'citizenship'" do
        it "lists the filtered results" do
          within ".filters" do
            check scope.name
          end

          expect(page).to have_css(".card--result", count: results.size)
        end
      end
    end
  end
end
