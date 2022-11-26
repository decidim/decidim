# frozen_string_literal: true

require "spec_helper"

module Decidim::Comments
  describe CommentThreadCell, type: :cell do
    controller Decidim::Comments::CommentsController

    subject { my_cell.call }

    let(:my_cell) { cell("decidim/comments/comment_thread", comment) }
    let(:organization) { create(:organization) }
    let(:participatory_process) { create :participatory_process, organization: }
    let(:component) { create(:component, participatory_space: participatory_process) }
    let(:commentable) { create(:dummy_resource, component:) }
    let(:comment) { create(:comment, commentable:) }

    context "when rendering" do
      it "renders the thread" do
        expect(subject).to have_css(".comment-thread")
        expect(subject).to have_content(comment.body.values.first)
      end
    end
  end
end
