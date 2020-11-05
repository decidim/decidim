# frozen_string_literal: true

require "spec_helper"

describe "Search proposals", type: :system do
  include_context "with a component"
  let(:manifest_name) { "proposals" }
  let!(:searchables) { create_list(:proposal, 3, component: component) }
  let!(:term) { translated(searchables.first.title).split(" ").last }
  let(:hashtag) { "#decidim" }

  before do
    hashtag_proposal = create(:proposal, component: component, title: "A proposal with a hashtag #{hashtag}")
    searchables << hashtag_proposal
    searchables.each { |s| s.update(published_at: Time.current) }
  end

  include_examples "searchable results"
end
