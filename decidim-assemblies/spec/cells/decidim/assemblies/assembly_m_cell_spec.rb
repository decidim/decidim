# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/space_cell_changes_button_text_cta"

module Decidim::Assemblies
  describe AssemblyMCell, type: :cell do
    controller Decidim::ApplicationController

    subject { cell("decidim/assemblies/assembly_m", model).call }

    let(:model) { create(:assembly, :published) }

    context "when rendering" do
      let(:show_space) { false }

      it "renders the card" do
        expect(subject).to have_css(".card--assembly")
      end

      it_behaves_like "space cell changes button text CTA"
    end
  end
end
