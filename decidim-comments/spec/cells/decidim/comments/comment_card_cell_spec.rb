# frozen_string_literal: true

require "spec_helper"

module Decidim::Comments
  describe CommentCardCell, type: :cell do
    controller Decidim::Comments::CommentsController

    subject { my_cell.call }

    let(:my_cell) { cell("decidim/comments/comment_card", comment) }
    let(:organization) { create(:organization) }
    let(:participatory_process) { create(:participatory_process, organization:) }
    let(:assembly) { create(:assembly, organization:) }
    let(:component) { create(:component, participatory_space: participatory_process) }
    let(:commentable) { create(:dummy_resource, component:) }
    let(:comment) { create(:comment, commentable:) }
    let(:created_at) { Time.current }

    context "when root commentable is deleted" do
      before do
        commentable.destroy!
        comment.reload
      end

      it "does not render the card" do
        expect(subject).to have_no_css("#comment_#{comment.id}")
      end
    end
  end
end
