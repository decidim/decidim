# frozen_string_literal: true

require "spec_helper"

module Decidim::Comments
  describe CommentCell, type: :cell do
    controller Decidim::Comments::CommentsController

    subject { my_cell.call }

    let(:my_cell) { cell("decidim/comments/comment", comment) }
    let(:organization) { create(:organization) }
    let(:participatory_process) { create(:participatory_process, organization:) }
    let(:component) { create(:component, participatory_space: participatory_process) }
    let(:commentable) { create(:dummy_resource, component:) }
    let(:comment) { create(:comment, commentable:) }

    context "when rendering" do
      it "renders the card" do
        expect(subject).to have_css("#comment_#{comment.id}")
        # An empty replies element is needed when dynamically adding replies
        expect(subject).to have_css("#comment-#{comment.id}-replies", text: "")
        expect(subject).to have_css(".comment__content")
        expect(subject).to have_css("button[data-dialog-open='loginModal'][title='#{I18n.t("decidim.components.comment.report.action")}']")
        expect(subject).to have_css("a[href='/processes/#{participatory_process.slug}/f/#{component.id}/dummy_resources/#{commentable.id}?commentId=#{comment.id}#comment_#{comment.id}']")
        expect(subject).to have_content(comment.body.values.first)
        expect(subject).to have_content("less than a minute")
        expect(subject).to have_content(comment.author.name)

        expect(subject).not_to have_css(".add-comment")
        expect(subject).not_to have_css(".comment-reply")
        expect(subject).not_to have_css("#flagModalComment#{comment.id}")
        expect(subject).not_to have_css(".label.alignment")
      end

      context "when deleted" do
        let(:comment) { create(:comment, :deleted, commentable:) }

        it "renders the card with a deletion message and replies" do
          expect(subject).to have_css("#comment_#{comment.id}")
          expect(subject).to have_css(".comment__deleted")
          expect(subject).not_to have_css("button[data-dialog-open='loginModal'][title='#{I18n.t("decidim.components.comment.report.action")}']")
          expect(subject).not_to have_css("a[href='/processes/#{participatory_process.slug}/f/#{component.id}/dummy_resources/#{commentable.id}?commentId=#{comment.id}#comment_#{comment.id}']")
          expect(subject).not_to have_content(comment.body.values.first)
          expect(subject).not_to have_content("less than a minute")
          expect(subject).to have_content(I18n.l(comment.deleted_at, format: :decidim_short))
          expect(subject).not_to have_content(comment.author.name)

          expect(subject).not_to have_css(".add-comment")
          expect(subject).not_to have_css(".comment-reply")
          expect(subject).not_to have_css("#flagModalComment#{comment.id}")
        end
      end

      context "when moderated" do
        let(:comment) { create(:comment, commentable:, created_at: 1.day.ago) }
        let!(:moderation) { create(:moderation, hidden_at: 6.hours.ago, reportable: comment) }

        it "renders the card with a moderation message and replies" do
          expect(subject).to have_css("#comment_#{comment.id}")
          expect(subject).to have_css(".comment__moderated")
          expect(subject).not_to have_css("button[data-dialog-open='loginModal'][title='#{I18n.t("decidim.components.comment.report.action")}']")
          expect(subject).not_to have_css("a[href='/processes/#{participatory_process.slug}/f/#{component.id}/dummy_resources/#{commentable.id}?commentId=#{comment.id}#comment_#{comment.id}']")
          expect(subject).not_to have_content(comment.body.values.first)
          expect(subject).not_to have_content("less than a minute")
          expect(subject).to have_content(I18n.l(moderation.hidden_at, format: :decidim_short))
          expect(subject).not_to have_content(comment.author.name)

          expect(subject).not_to have_css(".add-comment")
          expect(subject).not_to have_css(".comment-reply")
          expect(subject).not_to have_css("#flagModalComment#{comment.id}")
        end
      end

      context "when edited" do
        before do
          allow(comment).to receive(:edited?).and_return(true)
        end

        it "renders the card with an Edited message" do
          expect(subject).to have_css("#comment_#{comment.id}")
          expect(subject).to have_css("#comment-#{comment.id}-replies", text: "")
          expect(subject).to have_css(".comment__content")
          expect(subject).to have_css("button[data-dialog-open='loginModal'][title='#{I18n.t("decidim.components.comment.report.action")}']")
          expect(subject).to have_css("a[href='/processes/#{participatory_process.slug}/f/#{component.id}/dummy_resources/#{commentable.id}?commentId=#{comment.id}#comment_#{comment.id}']")
          expect(subject).to have_content("Edited")
          expect(subject).to have_content(comment.body.values.first)
          expect(subject).to have_content("less than a minute")
          expect(subject).to have_content(comment.author.name)

          expect(subject).not_to have_css(".add-comment")
          expect(subject).not_to have_css(".comment-reply")
          expect(subject).not_to have_css(".label.alignment")
        end
      end

      context "with votes" do
        let(:comment) { create(:comment, commentable:) }

        before do
          allow(commentable).to receive(:comments_have_votes?).and_return(true)

          create_list(:comment_vote, 4, :up_vote, comment:)
          create_list(:comment_vote, 2, :down_vote, comment:)
        end

        it "renders the votes buttons" do
          expect(subject).to have_css(".comment__votes .js-comment__votes--up[data-dialog-open='loginModal']")
          expect(subject).to have_css(".comment__votes .js-comment__votes--down[data-dialog-open='loginModal']")
          expect(subject).to have_css(".js-comment__votes--up span", text: 4)
          expect(subject).to have_css(".js-comment__votes--down span", text: 2)
        end
      end

      context "with alignment" do
        context "when positive alignment" do
          let(:comment) { create(:comment, commentable:) }

          before do
            comment.update!(alignment: 1)
          end

          it "renders the correct alignment badge" do
            expect(subject).to have_css(".label.alignment.success", text: "In favor")
          end
        end

        context "when negative alignment" do
          let(:comment) { create(:comment, commentable:) }

          before do
            comment.update!(alignment: -1)
          end

          it "renders the correct alignment badge" do
            expect(subject).to have_css(".label.alignment.alert", text: "Against")
          end
        end
      end

      context "with replies" do
        let(:resource_locator) { Decidim::ResourceLocatorPresenter.new(commentable) }
        let!(:replies) { create_list(:comment, 10, commentable: comment) }

        before do
          allow(Decidim::ResourceLocatorPresenter).to receive(:new).and_return(resource_locator)
          allow(resource_locator).to receive(:path).and_return("/dummies")
        end

        it "renders the replies" do
          element = subject.find("#comment-#{comment.id}-replies")
          replies.each do |reply|
            expect(element).to have_css("#comment_#{reply.id}")
            expect(element).to have_content(reply.body.values.first)
          end
        end
      end

      context "when signed in" do
        let(:current_user) { create(:user, :confirmed, organization: component.organization) }

        before do
          allow(controller).to receive(:current_user).and_return(current_user)
        end

        it "renders the reply form" do
          expect(subject).to have_css(".add-comment")
          expect(subject).to have_css(".comment__actions button")
          expect(subject).to have_css("button[data-dialog-open='flagModalComment#{comment.id}']")
          expect(subject).to have_css("#flagModalComment#{comment.id}")
        end

        context "with votes" do
          before do
            allow(commentable).to receive(:comments_have_votes?).and_return(true)
          end

          it "renders the votes buttons" do
            expect(subject).to have_css("form.button_to[action='/comments/#{comment.id}/votes?weight=-1']")
            expect(subject).to have_css("form.button_to[action='/comments/#{comment.id}/votes?weight=1']")
          end

          context "with own vote" do
            before do
              create(:comment_vote, :up_vote, comment:, author: current_user)
            end

            it "renders the opposite vote button disabled" do
              expect(subject).not_to have_css(".js-comment__votes--up[disabled='disabled']")
              expect(subject).to have_css(".js-comment__votes--down[disabled='disabled']")
            end
          end
        end
      end
    end

    describe "#vote_button_to" do
      context "when commentable has permissions set for the vote_comment action" do
        let(:permissions) do
          {
            vote_comment: {
              authorization_handlers: {
                "dummy_authorization_handler" => { "options" => {} }
              }
            }
          }
        end

        let(:user) { create(:user, :confirmed, organization:) }

        before do
          organization.available_authorizations = ["dummy_authorization_handler"]
          organization.save!
          commentable.create_resource_permission(permissions:)
          allow(commentable).to receive(:comments_have_votes?).and_return(true)
          allow(subject).to receive(:current_user).and_return(user)
        end

        it "renders an action_authorized button" do
          expect(subject).to have_css("[data-dialog-open=\"authorizationModal\"]")
        end
      end

      context "when commentable has no permissions set for the vote_comment action" do
        it "renders a plain button" do
          expect(subject).not_to have_css("[data-dialog-open=\"authorizationModal\"]")
        end
      end
    end
  end
end
