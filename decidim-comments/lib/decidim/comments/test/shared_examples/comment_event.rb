# frozen_string_literal: true

require "spec_helper"

shared_context "when it is a comment event" do
  include Decidim::ComponentPathHelper
  include Decidim::SanitizeHelper

  include_context "when a simple event"

  let(:resource) { comment.commentable }

  let(:comment) { create(:comment) }
  let(:comment_author) { comment.author }
  let(:normalized_comment_author) { comment.author }
  let(:comment_author_name) { decidim_html_escape comment.author.name }

  let(:extra) { { comment_id: comment.id } }
  let(:resource_title) { decidim_sanitize_translated(resource.title) }
end

shared_examples_for "a comment event" do
  it_behaves_like "a simple event"

  describe "author" do
    it "returns the comment author" do
      expect(subject.author).to eq(comment_author)
    end
  end

  describe "resource_text" do
    it "outputs the comment body" do
      expect(subject.resource_text).to eq comment.formatted_body
    end
  end

  describe "hidden_resource?" do
    context "when comment is not moderated" do
      it "returns false" do
        expect(subject.hidden_resource?).to be false
      end
    end

    context "when comment is moderated" do
      let(:comment) { create(:comment, :moderated) }

      it "returns true" do
        expect(subject.hidden_resource?).to be true
      end
    end

    context "when resource is not moderated" do
      it "returns false" do
        expect(subject.hidden_resource?).to be false
      end
    end

    context "when resource is moderated" do
      before do
        create(:moderation, reportable: resource, hidden_at: 2.days.ago)
        resource.reload
      end

      it "returns true" do
        expect(subject.hidden_resource?).to be true
      end
    end
  end
end
