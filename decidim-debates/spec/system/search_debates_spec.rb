# frozen_string_literal: true

require "spec_helper"

describe "Search debates" do
  include ActionView::Helpers::SanitizeHelper

  include_context "with a component"
  let(:manifest_name) { "debates" }
  let!(:searchables) { create_list(:debate, 3, component:) }
  let!(:term) { strip_tags(translated(searchables.first.title)).split.last }
  let(:hashtag) { "#decidim" }

  before do
    hashtag_debate = create(:debate, component:, title: { en: "A debate with a hashtag #{hashtag}" })
    searchables << hashtag_debate
  end

  include_examples "searchable results"
end
