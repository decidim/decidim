# frozen_string_literal: true

require "spec_helper"

describe Decidim::CardLCell, type: :cell do
  subject { cell_html }

  controller Decidim::PagesController

  let!(:model) { create(:dummy_resource) }
  let(:my_cell) { cell("decidim/card_l", model) }
  let(:cell_html) { my_cell.call }

  before do
    allow(model).to receive(:description).and_return(model.body)
  end

  it_behaves_like "m-cell", :model
end
