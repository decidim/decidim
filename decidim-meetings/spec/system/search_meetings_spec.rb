# frozen_string_literal: true

require "spec_helper"

describe "Search meetings", type: :system do
  include_context "with a component"
  let(:manifest_name) { "meetings" }
  let!(:searchables) { create_list(:meeting, 3, component: component) }
  let!(:term) { searchables.first.title["en"].split(" ").sample }

  include_examples "searchable results"
end
