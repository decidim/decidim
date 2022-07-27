# frozen_string_literal: true

require "spec_helper"

describe "Show a Proposal", type: :system do
  include_context "with a component"
  let(:manifest_name) { "proposals" }
  let(:proposal) { create :proposal, component: }

  def visit_proposal
    visit resource_locator(proposal).path
  end

  describe "proposal show" do
    it_behaves_like "editable content for admins" do
      let(:target_path) { resource_locator(proposal).path }
    end

    context "when requesting the proposal path" do
      before do
        visit_proposal
      end

      it_behaves_like "share link"

      describe "extra admin link" do
        before do
          login_as user, scope: :user
          visit current_path
        end

        context "when I'm an admin user" do
          let(:user) { create(:user, :admin, :confirmed, organization:) }

          it "has a link to answer to the proposal at the admin" do
            within ".topbar" do
              expect(page).to have_link("Answer", href: /.*admin.*proposal-answer.*/)
            end
          end
        end

        context "when I'm a regular user" do
          let(:user) { create(:user, :confirmed, organization:) }

          it "does not have a link to answer the proposal at the admin" do
            within ".topbar" do
              expect(page).not_to have_link("Answer")
            end
          end
        end
      end

      describe "author tooltip" do
        let(:user) { create(:user, :confirmed, organization:) }

        before do
          login_as user, scope: :user
          visit current_path
        end

        context "when author doesn't restrict messaging" do
          it "includes a link to message the proposal author" do
            within ".author-data" do
              find_link.hover
            end
            expect(page).to have_link("Send private message")
          end
        end
      end
    end
  end
end
