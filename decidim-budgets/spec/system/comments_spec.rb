# frozen_string_literal: true

require "spec_helper"

describe "Comments", type: :system do
  let!(:component) { create(:budgets_component, organization: organization) }
  let!(:budget) { create(:budget, component: component) }
  let!(:commentable) { create(:project, budget: budget) }
  let(:resource_path) { resource_locator([budget, commentable]).path }

  include_examples "comments"

  context "when requesting the comments index with a non-XHR request" do
    it "redirects the user to the correct commentable path" do
      visit decidim_comments.comments_path(commentable_gid: commentable.to_signed_global_id.to_s)

      expect(page).to have_current_path(
        decidim_budgets.budget_project_path(budget, commentable)
      )
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
