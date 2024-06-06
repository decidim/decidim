# frozen_string_literal: true

require "spec_helper"

describe "Search comments", type: :system do
  include_context "with a component"
  let(:manifest_name) { "dummy" }
  let!(:commentable) { create(:dummy_resource, component: component) }
  let!(:searchables) { create_list(:comment, 3, commentable: commentable) }
  let!(:term) { "FooBar" }
  let(:hashtag) { "#decidim" }

  before do
    comment = create(:comment, body: "FooBar", commentable:)
    searchables << comment

    hashtag_comment = create(:comment, body: "A comment with a hashtag #{hashtag}", commentable: commentable)
    searchables << hashtag_comment
  end

  include_examples "searchable results"
end
