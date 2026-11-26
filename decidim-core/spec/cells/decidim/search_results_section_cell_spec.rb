# frozen_string_literal: true

require "spec_helper"

describe Decidim::SearchResultsSectionCell, type: :cell do
  subject { cell_html }

  controller Decidim::SearchesController

  let(:organization) { create(:organization) }
  let(:participatory_space) { create(:participatory_process, :published, :with_phases, organization:) }
  let(:component) { create(:proposal_component, participatory_space:) }
  let(:results) { Kaminari.paginate_array(create_list(:proposal, 26, component:)).page(1).per(25) }
  let(:model) { { "Decidim::Proposals::Proposal" => { count: 26, results: } } }
  # A real view_context is needed for Kaminari to find its `decidim` theme partials: without one
  # the cell uses `ActionController::Base.helpers`, whose lookup_context has no view paths.
  let(:my_cell) { cell("decidim/search_results_section", model, is_paginated: true, context: { view_context: controller.view_context }) }
  let(:cell_html) { my_cell.call }

  before do
    allow(my_cell).to receive(:url_for).and_return("/")
  end

  it "renders the pagination links" do
    expect(subject).to have_css("[data-pagination]")
    expect(subject).to have_text("Results per page")
  end
end
