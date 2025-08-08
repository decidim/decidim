# frozen_string_literal: true

require "spec_helper"

describe "Search comments" do
  include ActionView::Helpers::SanitizeHelper

  include_context "with a component"
  let(:manifest_name) { "dummy" }
  let!(:commentable) { create(:dummy_resource, component:) }
  let!(:searchables) { create_list(:comment, 3, commentable:) }
  let!(:term) { "FooBar" }

  before do
    comment = create(:comment, body: "FooBar", commentable:)
    searchables << comment
  end

  include_examples "searchable results"
end
