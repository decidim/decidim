require "spec_helper"

describe "Explore results", type: :feature do
  let(:organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, organization: organization) }
  let(:current_feature) { create :feature, participatory_process: participatory_process, manifest_name: "results" }
  let(:results_count) { 5 }
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
        # TODO: check correct data
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
  end
end
