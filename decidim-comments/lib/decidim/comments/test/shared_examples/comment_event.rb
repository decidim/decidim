# frozen_string_literal: true

require "spec_helper"

shared_context "when it's a comment event" do
  include Decidim::ComponentPathHelper
  include Decidim::SanitizeHelper

  include_context "when a simple event"

  let(:resource) { comment.commentable }

  let(:comment) { create :comment }
  let(:comment_author) { comment.author }
  let(:normalized_comment_author) { comment.author }
  let(:comment_author_name) { decidim_html_escape comment.author.name }

  let(:extra) { { comment_id: comment.id } }
  let(:resource_title) { decidim_html_escape(translated(resource.title)) }
  let(:user_group) do
    user_group = create(:user_group, :verified, organization:, users: [comment_author])
    comment.update!(user_group:)
    user_group
  end
end

shared_examples_for "a comment event" do
  it_behaves_like "a simple event"

  describe "author" do
    it "returns the comment author" do
      if defined? user_group_author
        expect(subject.author).to eq(user_group_author)
      else
        expect(subject.author).to eq(comment_author)
      end
    end
  end

  describe "resource_text" do
    it "outputs the comment body" do
      expect(subject.resource_text).to eq comment.formatted_body
    end
  end
end
