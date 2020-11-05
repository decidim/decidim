# frozen_string_literal: true

require "spec_helper"

module Decidim::Comments
  describe CommentActivityCell, type: :cell do
    controller Decidim::LastActivitiesController

    let!(:comment) { create(:comment) }
    let(:action_log) do
      create(
        :action_log,
        resource: comment,
        organization: comment.organization,
        component: comment.component,
        participatory_space: comment.participatory_space
      )
    end

    context "when rendering" do
      it "renders the card" do
        html = cell("decidim/comments/comment_activity", action_log).call
        expect(html).to have_css(".card__content")
        expect(html).to have_content("New comment at #{translated comment.root_commentable.title}")
        expect(html).to have_content(comment.body.values.first)
      end

      context "when the comment has mentions" do
        before do
          body = "Comment mentioning some user, @#{comment.author.nickname}"
          parsed_body = Decidim::ContentProcessor.parse(body, current_organization: comment.organization)
          comment.body = { en: parsed_body.rewrite }
          comment.save
        end

        it "correctly renders comments with mentions" do
          html = cell("decidim/comments/comment_activity", action_log).call
          expect(html).to have_no_content("gid://")
          expect(html).to have_content("@#{comment.author.nickname}")
        end
      end

      context "when the commentable is missing" do
        before do
          comment.root_commentable.delete
        end

        it "does not render" do
          expect(described_class.new(action_log)).not_to be_renderable
        end
      end

      context "when the commentable is a comment" do
        let!(:comment) { create(:comment, :comment_on_comment) }

        it "renders the card" do
          html = cell("decidim/comments/comment_activity", action_log).call
          expect(html).to have_css(".card__content")
          expect(html).to have_content("New comment at #{translated comment.root_commentable.title}")
          expect(html).to have_content(comment.body.values.first)
        end
      end
    end
  end
end
