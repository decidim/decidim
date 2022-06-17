# frozen_string_literal: true

require "spec_helper"

describe "Search proposals", type: :system do
  include_context "with a component"
  let(:participatory_process) do
    create(:participatory_process, :published, :with_steps, organization:)
  end
  let(:manifest_name) { "proposals" }
  let!(:searchables) { create_list(:proposal, 3, component:) }
  let!(:term) { translated(searchables.first.title).split.last }
  let(:component) { create(:proposal_component, participatory_space: participatory_process) }
  let(:hashtag) { "#decidim" }

  before do
    hashtag_proposal = create(:proposal, component:, title: "A proposal with a hashtag #{hashtag}")
    searchables << hashtag_proposal
    searchables.each { |s| s.update(published_at: Time.current) }
  end

  include_examples "searchable results"
end
