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
        expect(html).to have_content("New comment at #{comment.commentable.title}")
        expect(html).to have_content(comment.body)
      end

      context "when the commentable is missing" do
        before do
          comment.commentable.delete
        end

        it "does not render" do
          expect(described_class.new(action_log)).not_to be_renderable
        end
      end
    end
  end
end
