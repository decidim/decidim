# frozen_string_literal: true

require "spec_helper"

shared_examples_for "has space in m-cell" do
  context "when rendering with show_space flag" do
    # expects the cell to be invoked with a :show_space context flag that takes this value.
    let(:show_space) { true }

    it "renders the space where the model belongs to" do
      expect(cell_html).to have_content(decidim_escape_translated(model.component.participatory_space.title))
    end
  end
end
