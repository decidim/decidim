# frozen_string_literal: true

require "spec_helper"

describe "Explore results", versioning: true, type: :system do
  include_context "with a component"

  let(:manifest_name) { "accountability" }
  let(:results_count) { 5 }
  let!(:scope) { create :scope, organization: organization }
  let!(:results) do
    create_list(
      :result,
      results_count,
      component: component
    )
  end

  before do
    visit path
  end

  describe "home" do
    let(:path) { decidim_participatory_process_accountability.root_path(participatory_process_slug: participatory_process.slug, component_id: component.id) }

    it "shows categories and subcategories with results" do
      participatory_process.categories.each do |category|
        results_count = Decidim::Accountability::ResultsCalculator.new(component, nil, category.id).count
        expect(page).to have_content(translated(category.name)) if !category.subcategories.empty? || results_count.positive?
      end
    end

    it "shows progress" do
      expect(page).to have_content("Global execution status")
      expect(page).to have_selector(".progress-figure")
    end

    context "with progress disabled" do
      before do
        component.update!(settings: { display_progress_enabled: false })
      end

      it "doesn't show progress" do
        visit path

        expect(page).to have_no_content("Global execution status")
        expect(page).to have_no_selector(".progress-figure")
      end
    end
  end

  describe "index" do
    let(:path) { decidim_participatory_process_accountability.results_path(participatory_process_slug: participatory_process.slug, component_id: component.id) }

    it "shows all results for the given process and category" do
      expect(page).to have_selector(".card--list__item", count: results_count)

      results.each do |result|
        expect(page).to have_content(translated(result.title))
      end
    end

    context "with a category and a scope" do
      let!(:category) { create :category, participatory_space: participatory_process }
      let!(:scope) { create :scope, organization: organization }
      let!(:result) do
        result = results.first
        result.category = category
        result.scope = scope
        result.save
        result
      end

      let(:path) do
        decidim_participatory_process_accountability.results_path(
          participatory_process_slug: participatory_process.slug, component_id: component.id, filter: { category_id: category.id, scope_id: scope.id }
        )
      end

      it "shows current scope active" do
        within "ul.tags.tags--action li.active" do
          expect(page).to have_content(translated(scope.name))
        end
      end

      it "maintains scope filter" do
        click_link translated(category.name)

        within "ul.tags.tags--action li.active" do
          expect(page).to have_content(translated(scope.name))
        end
      end
    end
  end

  describe "show" do
    let(:path) { decidim_participatory_process_accountability.result_path(id: result.id, participatory_process_slug: participatory_process.slug, component_id: component.id) }
    let(:results_count) { 1 }
    let(:result) { results.first }

    it "shows all result info" do
      expect(page).to have_i18n_content(result.title)
      expect(page).to have_i18n_content(result.description)
      expect(page).to have_content(result.reference)
      expect(page).to have_content("#{result.progress.to_i}%")
    end

    context "when it has no versions" do
      before do
        result.versions.destroy_all
        visit current_path
      end

      it "does not show version data" do
        expect(page).not_to have_content("Version number")
      end
    end

    context "when it has some versions" do
      it "does shows version data" do
        expect(page).to have_content("Version number 1")
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
        result.category = create :category, participatory_space: participatory_process
        result.save
        result
      end

      it "shows tags for category" do
        expect(page).to have_selector("ul.tags.tags--result")
        within "ul.tags.tags--result" do
          expect(page).to have_content(translated(result.category.name))
        end
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
          expect(page).to have_content(translated(result.scope.name))
        end
      end
    end

    context "when a proposal has comments" do
      let(:result) { results.first }
      let(:author) { create(:user, :confirmed, organization: component.organization) }
      let!(:comments) { create_list(:comment, 3, commentable: result) }

      before do
        visit current_path
      end

      it "shows the comments" do
        comments.each do |comment|
          expect(page).to have_content(comment.body.values.first)
        end
      end
    end

    context "with linked proposals" do
      let(:proposal_component) do
        create(:component, manifest_name: :proposals, participatory_space: result.component.participatory_space)
      end
      let(:proposals) { create_list(:proposal, 3, component: proposal_component) }
      let(:proposal) { proposals.first }

      before do
        result.link_resources(proposals, "included_proposals")
        visit current_path
      end

      it "shows related proposals" do
        proposals.each do |proposal|
          expect(page).to have_content(translated(proposal.title))
          expect(page).to have_content(proposal.creator_author.name)
          expect(page).to have_content(proposal.votes.size)
        end
      end

      it "the result is mentioned in the proposal page" do
        click_link translated(proposal.title)
        expect(page).to have_i18n_content(result.title)
      end
    end

    context "with linked projects" do
      let(:budgets_component) do
        create(:component, manifest_name: :budgets, participatory_space: result.component.participatory_space)
      end
      let(:budget) { create(:budget, component: budgets_component) }
      let(:projects) { create_list(:project, 3, budget: budget) }
      let(:project) { projects.first }

      before do
        result.link_resources(projects, "included_projects")
        visit current_path
      end

      it "shows related projects" do
        projects.each do |project|
          expect(page).to have_content(translated(project.title))
        end
      end

      it "the result is mentioned in the project page" do
        click_link translated(project.title)
        expect(page).to have_i18n_content(result.title)
      end
    end

    context "with linked meetings" do
      let(:meeting_component) do
        create(:component, manifest_name: :meetings, participatory_space: result.component.participatory_space)
      end
      let(:meetings) { create_list(:meeting, 3, component: meeting_component) }
      let(:meeting) { meetings.first }

      before do
        result.link_resources(meetings, "meetings_through_proposals")
        visit current_path
      end

      it "shows related meetings" do
        meetings.each do |meeting|
          expect(page).to have_i18n_content(meeting.title)
          expect(page).to have_i18n_content(meeting.description)
        end
      end

      it "the result is mentioned in the meeting page" do
        click_link translated(meeting.title)
        expect(page).to have_i18n_content(result.title)
      end
    end

    context "when filtering" do
      before do
        create(:result, component: component, scope: scope)
        visit_component
      end

      context "when the process has a linked scope" do
        before do
          participatory_process.update(scope: scope)
          visit current_path
        end

        it "enables filtering by scope" do
          within ".scope-filters" do
            expect(page).not_to have_content(/Scopes/i)
          end
        end
      end

      context "when the process has no linked scope" do
        before do
          participatory_process.update(scope: nil)
          visit current_path
        end

        it "enables filtering by scope" do
          within ".scope-filters" do
            expect(page).to have_content(/Scopes/i)
          end
        end
      end
    end
  end
end
