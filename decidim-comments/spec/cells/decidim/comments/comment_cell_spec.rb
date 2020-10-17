# frozen_string_literal: true

require "spec_helper"

module Decidim::Comments
  describe CommentCell, type: :cell do
    controller Decidim::Comments::CommentsController

    subject { my_cell.call }

    let(:my_cell) { cell("decidim/comments/comment", comment) }
    let(:organization) { create(:organization) }
    let(:participatory_process) { create :participatory_process, organization: organization }
    let(:component) { create(:component, participatory_space: participatory_process) }
    let(:commentable) { create(:dummy_resource, component: component) }
    let(:comment) { create(:comment, commentable: commentable) }

    context "when rendering" do
      it "renders the card" do
        expect(subject).to have_css("#comment_#{comment.id}")
        # An empty replies element is needed when dynamically adding replies
        expect(subject).to have_css("#comment-#{comment.id}-replies", text: "")
        expect(subject).to have_css(".comment__content")
        expect(subject).to have_css("button[data-open='loginModal'][title='#{I18n.t("decidim.components.comment.report.title")}']")
        expect(subject).to have_css("a[href='/processes/#{participatory_process.slug}/f/#{component.id}/dummy_resources/#{commentable.id}?commentId=#{comment.id}#comment_#{comment.id}']")
        expect(subject).to have_content(comment.body.values.first)
        expect(subject).to have_content(I18n.l(comment.created_at, format: :decidim_short))
        expect(subject).to have_content(comment.author.name)

        expect(subject).not_to have_css(".comment__additionalreply")
        expect(subject).not_to have_css(".add-comment")
        expect(subject).not_to have_css(".comment__reply")
        expect(subject).not_to have_css("#flagModalComment#{comment.id}")
        expect(subject).not_to have_css(".label.alignment")
      end

      context "with votes" do
        let(:comment) { create(:comment, commentable: commentable) }

        before do
          allow(commentable).to receive(:comments_have_votes?).and_return(true)

          create_list(:comment_vote, 4, :up_vote, comment: comment)
          create_list(:comment_vote, 2, :down_vote, comment: comment)
        end

        it "renders the votes buttons" do
          expect(subject).to have_css(".comment__votes .comment__votes--up[data-open='loginModal']")
          expect(subject).to have_css(".comment__votes .comment__votes--down[data-open='loginModal']")
          expect(subject).to have_css(".comment__votes--up .comment__votes--count", text: 4)
          expect(subject).to have_css(".comment__votes--down .comment__votes--count", text: 2)
        end
      end

      context "with alignment" do
        context "when positive alignment" do
          let(:comment) { create(:comment, commentable: commentable) }

          before do
            comment.update!(alignment: 1)
          end

          it "renders the correct alignment badge" do
            expect(subject).to have_css(".label.alignment.success", text: "In favor")
          end
        end

        context "when negative alignment" do
          let(:comment) { create(:comment, commentable: commentable) }

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
          expect(subject).to have_css(".comment__additionalreply")
          expect(subject).to have_css(".add-comment")
          expect(subject).to have_css(".comment__reply", count: 2)

          expect(subject).to have_css("button[data-open='flagModalComment#{comment.id}']")
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
        end
      end
    end
  end
end
