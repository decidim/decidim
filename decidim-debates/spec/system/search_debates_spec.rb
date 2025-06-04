# frozen_string_literal: true

require "spec_helper"

describe "Search debates" do
  include ActionView::Helpers::SanitizeHelper

  include_context "with a component"
  let(:manifest_name) { "debates" }
  let!(:searchables) { create_list(:debate, 3, component:) }
  let!(:term) { strip_tags(translated(searchables.first.title)).split.last }

  before do
    debate = create(:debate, component:, title: { en: "A debate" })
    searchables << debate
  end

  include_examples "searchable results"
end
