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

  context "when there is a link in the comment search result" do
    let(:search_input_selector) { "input#input-search" }

    before do
      create(:comment, body: "Here is an interesting link: https://github.com/decidim", commentable:)
      visit decidim.root_path
      field = find(search_input_selector)
      field.set "Here is an interesting"
      send_keys(:enter)
    end

    it "does not allow clickable link" do
      expect(page).to have_no_link(href: "https://github.com/decidim")
      expect(page).to have_text("Here is an interesting link: https://github.com/decidim")
    end
  end

  include_examples "searchable results"
end
