# frozen_string_literal: true

require "spec_helper"

describe "Search proposals" do
  include ActionView::Helpers::SanitizeHelper

  include_context "with a component"
  let(:participatory_process) do
    create(:participatory_process, :published, :with_steps, organization:)
  end
  let(:manifest_name) { "proposals" }
  let!(:searchables) { create_list(:proposal, 3, component:) }
  let!(:term) { strip_tags(translated(searchables.first.title)).split.sample }
  let(:component) { create(:proposal_component, participatory_space: participatory_process) }

  before do
    searchables << create(:proposal, component:, title: "A proposal with a title")
    searchables.each { |s| s.update(published_at: Time.current) }
  end

  include_examples "searchable results"
end
