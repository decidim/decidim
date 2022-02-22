# frozen_string_literal: true

require "spec_helper"

describe Decidim::Comments::CommentDownvotedEvent do
  let(:event_name) { "decidim.events.comments.comment_downvoted" }
  let(:weight) { -1 }

  context "with leaf comment" do
    it_behaves_like "a comment voted event" do
      let(:parent_comment) { create(:comment) }
      let(:comment) { create :comment, commentable: parent_comment, root_commentable: parent_comment.root_commentable }
      let(:resource_title) { decidim_html_escape(translated(resource.commentable.title)) }
      let(:resource_path) { resource_locator(resource.commentable).path }
    end
  end

  context "with root comment" do
    it_behaves_like "a comment voted event" do
      let(:resource) { comment.commentable }
      let(:comment) { create :comment }
      let(:resource_title) { decidim_html_escape(translated(resource.title)) }

      it_behaves_like "a translated comment event" do
        let(:translatable) { false }
      end
    end
  end
end
