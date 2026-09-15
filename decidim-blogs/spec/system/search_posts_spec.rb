# frozen_string_literal: true

require "spec_helper"

describe "Search posts" do
  include ActionView::Helpers::SanitizeHelper

  include_context "with a component"
  let(:manifest_name) { "blogs" }
  let!(:searchables) { create_list(:post, 3, component:) }
  let!(:term) { strip_tags(translated(searchables.first.title)).split.last }

  before do
    searchables << create(:post, component:, title: { en: "A post with a title" })
  end

  include_examples "searchable results"
end
