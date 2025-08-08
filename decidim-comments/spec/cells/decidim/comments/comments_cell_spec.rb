# frozen_string_literal: true

require "spec_helper"

module Decidim::Comments
  describe CommentsCell, type: :cell do
    controller Decidim::Comments::CommentsController

    subject { my_cell.call }

    let(:my_cell) { cell("decidim/comments/comments", comment.commentable) }
    let(:organization) { create(:organization) }
    let(:participatory_process) { create(:participatory_process, organization:) }
    let(:component) { create(:component, participatory_space: participatory_process) }
    let(:commentable) { create(:dummy_resource, component:) }
    let(:comment) { create(:comment, commentable:) }

    context "when rendering" do
      it "renders the thread" do
        expect(subject).to have_css(".comments-count", text: "1 comment")
        expect(subject).to have_css(".flash.primary.loading-comments", text: "Loading comments ...")
        expect(subject).to have_no_content(comment.body.values.first)
        expect(subject).to have_no_css(".add-comment")
        expect(subject).to have_content("Log in or create an account to add your comment.")

        {
          best_rated: "Best rated",
          recent: "Recent",
          older: "Older",
          most_discussed: "Most discussed"
        }.each do |key, title|
          expect(subject).to have_css("select#order option[value='#{key}']", text: title)
        end
      end

      context "with the single comment defined" do
        let(:my_cell) { cell("decidim/comments/comments", comment.commentable, single_comment: comment.id) }
        let!(:other_comments) { create_list(:comment, 10, commentable:) }

        it "renders only the single comment" do
          expect(subject).to have_content(comment.body.values.first)

          other_comments.each do |other_comment|
            expect(subject).to have_no_content(other_comment.body.values.first)
          end
        end

        it "renders the single comment warning" do
          expect(subject).to have_css(".flash.secondary", text: "You are seeing a single comment")
          expect(subject).to have_css(".flash.secondary", text: "View all comments")
        end

        context "with the single comment being moderated" do
          before do
            create(
              :moderation,
              :hidden,
              reportable: comment,
              participatory_space: commentable.participatory_space
            )
          end

          it "renders the thread" do
            expect(subject).to have_css(".flash.primary.loading-comments", text: "Loading comments ...")
            expect(subject).to have_no_content(comment.body.values.first)
            expect(subject).to have_no_css(".add-comment")
          end

          it "renders the single comment warning" do
            expect(subject).to have_css(".flash.secondary", text: "You are seeing a single comment")
            expect(subject).to have_css(".flash.secondary", text: "View all comments")
          end
        end
      end

      context "when signed in" do
        let(:current_user) { create(:user, :confirmed, organization: component.organization) }

        before do
          allow(controller).to receive(:current_user).and_return(current_user)
          allow(controller).to receive(:user_signed_in?).and_return(true)
        end

        it "renders the add comment form" do
          expect(subject).to have_css(".add-comment #new_comment_for_DummyResource_#{commentable.id}")
        end

        context "when comments are blocked" do
          before do
            comment # Create the comment before disabling comments
            allow(commentable).to receive(:accepts_new_comments?).and_return(false)
            allow(commentable).to receive(:user_allowed_to_comment?).with(current_user).and_return(true)
          end

          it "renders the comments blocked warning" do
            expect(subject).to have_css(".flash.warning", text: I18n.t("decidim.components.comments.blocked_comments_warning"))
            expect(subject).to have_no_css(".flash.warning", text: I18n.t("decidim.components.comments.blocked_comments_for_user_warning"))
            expect(subject).to have_no_css(".add-comment #new_comment_for_DummyResource_#{commentable.id}")
          end

          context "and the user is an admin" do
            let(:current_user) { create(:user, :admin, :confirmed, organization: component.organization) }

            it "renders add comment" do
              expect(subject).to have_css(".add-comment #new_comment_for_DummyResource_#{commentable.id}")
            end
          end

          context "and the user is a user manager" do
            let(:current_user) { create(:user, :user_manager, :confirmed, organization: component.organization) }

            it "renders add comment" do
              expect(subject).to have_css(".add-comment #new_comment_for_DummyResource_#{commentable.id}")
            end
          end

          context "and the user is a evaluator in the same participatory space" do
            let!(:evaluator_role) { create(:participatory_process_user_role, user: current_user, participatory_process: component.participatory_space, role: :evaluator) }

            it "renders add comment" do
              expect(subject).to have_css(".add-comment #new_comment_for_DummyResource_#{commentable.id}")
            end
          end

          context "and the user is a evaluator in a different participatory space" do
            let!(:evaluator_role) { create(:participatory_process_user_role, user: current_user, role: :evaluator) }

            it "does not render add comment" do
              expect(subject).to have_no_css(".add-comment #new_comment_for_DummyResource_#{commentable.id}")
            end
          end
        end

        context "when user comments are blocked" do
          before do
            allow(commentable).to receive(:user_allowed_to_comment?).with(current_user).and_return(false)
            allow(commentable).to receive(:user_authorized_to_comment?).with(current_user).and_return(true)
          end

          it "renders the user comments blocked warning" do
            expect(subject).to have_no_css(".flash.warning", text: I18n.t("decidim.components.comments.blocked_comments_for_unauthorized_user_warning"))
            expect(subject).to have_css(".flash.warning", text: I18n.t("decidim.components.comments.blocked_comments_for_user_warning"))
          end
        end

        context "when user is not authorized to comment" do
          let(:permissions) do
            {
              comment: {
                authorization_handlers: {
                  "dummy_authorization_handler" => { "options" => {} }
                }
              }
            }
          end

          before do
            organization.available_authorizations = ["dummy_authorization_handler"]
            organization.save!
            commentable.create_resource_permission(permissions:)
            allow(commentable).to receive(:user_allowed_to_comment?).with(current_user).and_return(false)
            allow(commentable).to receive(:user_authorized_to_comment?).with(current_user).and_return(false)
          end

          it "renders the user not authorized to comment warning" do
            expect(subject).to have_css(".flash.warning", text: I18n.t("decidim.components.comments.blocked_comments_for_unauthorized_user_warning"))
            expect(subject).to have_no_css(".flash.warning", text: I18n.t("decidim.components.comments.blocked_comments_for_user_warning"))
          end
        end
      end

      context "when two_columns_layout? is true" do
        let(:current_user) { create(:user, :confirmed, organization: component.organization) }

        before do
          allow(controller).to receive(:current_user).and_return(current_user)
          allow(controller).to receive(:user_signed_in?).and_return(true)
          commentable.define_singleton_method(:two_columns_layout?) { true }
          allow(commentable).to receive(:closed?).and_return(false)
        end

        it "calls render_comments_in_two_columns" do
          expect(my_cell).to receive(:render_comments_in_two_columns)
          my_cell.render_comments
        end

        it "renders the comments in two columns layout" do
          my_cell.render_comments
          expect(subject).to have_css(".comments-two-columns")
        end

        context "when alignment is enabled" do
          before do
            allow(commentable).to receive(:comments_have_alignment?).and_return(true)
          end

          it "renders the alignment buttons" do
            expect(subject).to have_css("button[data-toggle-ok]")
            expect(subject).to have_css("button[data-toggle-ko]")
          end
        end
      end

      context "when supports_two_columns_layout? is false" do
        before do
          allow(commentable).to receive(:two_columns_layout?).and_return(false)
          allow(my_cell).to receive(:two_columns_layout?).and_return(false)
        end

        it "does not call render_comments_in_two_columns" do
          expect(my_cell).not_to receive(:render_comments_in_two_columns)
          my_cell.render_comments
        end

        it "renders the comments in single column layout" do
          my_cell.render_comments
          expect(subject).to have_no_css(".comments-two-columns")
          expect(subject).to have_css(".comment-threads")
        end
      end
    end
  end
end
