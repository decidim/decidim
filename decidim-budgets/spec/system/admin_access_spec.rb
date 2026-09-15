# frozen_string_literal: true

require "spec_helper"

require "decidim/admin/test/admin_participatory_space_component_access_examples"

describe "AdminAccess" do
  let(:manifest_name) { "budgets" }
  let(:budget) { create(:budget, component:) }
  let!(:project) { create(:project, budget:) }
  let(:title) { "Budgets" }

  include_context "when managing a component as an admin"
  include_examples "accessing the component in a participatory space"

  describe "when accessing projects" do
    context "when the user is a process admin" do
      let(:user) { create(:process_admin, :confirmed, organization:, participatory_process:) }

      before do
        login_as user, scope: :user
      end

      it "access the projects' index page" do
        click_on(translated(budget.title))
        expect(page).to have_text(translated(project.title))
      end
    end
  end
end
