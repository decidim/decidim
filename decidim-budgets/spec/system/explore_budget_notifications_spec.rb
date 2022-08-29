# frozen_string_literal: true

require "spec_helper"

describe "Explore budget notifications", :slow, type: :system do
  include_context "with a component"
  let(:manifest_name) { "budgets" }
  let(:budget) { create :budget, component: }
  let(:projects_count) { 5 }
  let!(:projects) do
    create_list(:project, projects_count, budget:)
  end
  let!(:project) { projects.first }

  describe "index" do
    context "when a budgeting project was commented in a followed space" do
      let(:user) { create(:user, :confirmed, organization: component.organization) }
      let(:other_user) { create(:user, :confirmed, organization: component.organization) }

      before do
        switch_to_host(organization.host)
        login_as(user, scope: :user)

        # Create a notification for the follower
        create(:follow, followable: component.participatory_space, user:)
        comment = create(:comment, commentable: project, author: other_user)
        perform_enqueued_jobs do
          Decidim::Comments::NewCommentNotificationCreator.new(comment, [], []).create
        end
      end

      it "displays the notification for the comment" do
        visit_notifications

        within "#notifications" do
          expect(page).to have_content(translated(project.title))
        end
      end
    end
  end

  private

  def visit_notifications
    page.visit decidim.notifications_path
  end
end
