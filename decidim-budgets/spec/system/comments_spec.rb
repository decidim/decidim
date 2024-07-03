# frozen_string_literal: true

require "spec_helper"

describe "Comments" do
  let!(:component) { create(:budgets_component, organization:) }
  let!(:budget) { create(:budget, component:) }
  let!(:commentable) { create(:project, budget:) }
  let(:resource_path) { resource_locator([budget, commentable]).path }

  include_examples "comments"

  context "with comments blocked" do
    let!(:component) { create(:budgets_component, participatory_space:, organization:) }
    let(:participatory_space) { create(:participatory_process, :with_steps, organization:) }

    include_examples "comments blocked"
  end

  context "when requesting the comments index with a non-XHR request" do
    it "redirects the user to the correct commentable path" do
      visit decidim_comments.comments_path(commentable_gid: commentable.to_signed_global_id.to_s)

      expect(page).to have_current_path(
        decidim_budgets.budget_project_path(budget, commentable)
      )
    end
  end

  describe "Get link" do
    it "opens single comment to another window" do
      visit decidim_budgets.budget_project_path(id: commentable.id, budget_id: budget.id)

      another_window = window_opened_by do
        within(".comment", match: :first) do
          page.find("[id^='dropdown-trigger']").click
          click_on "Get link"
        end
      end

      within_window(another_window) do
        expect(page).to have_content(decidim_sanitize_translated(commentable.title))
        expect(page).to have_content(decidim_sanitize_translated(comments.first.body))
        expect(page).to have_no_content(decidim_sanitize_translated(comments.second.body))
      end
    end
  end

  private

  def decidim_comments
    Decidim::Comments::Engine.routes.url_helpers
  end

  def decidim_budgets
    Decidim::EngineRouter.main_proxy(component)
  end
end
