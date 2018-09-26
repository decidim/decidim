# frozen_string_literal: true

require "spec_helper"

describe "Search proposals", type: :system do
  include_context "with a component"
  let(:manifest_name) { "proposals" }
  let!(:searchables) { create_list(:proposal, 3, component: component) }
  let!(:term) { searchables.first.title.split(" ").sample }

  before do
    searchables.each { |s| s.update(published_at: Time.current) }
  end

  include_examples "searchable results"
end
