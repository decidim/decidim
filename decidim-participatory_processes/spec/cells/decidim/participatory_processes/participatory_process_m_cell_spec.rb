# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/space_cell_changes_button_text_cta"

module Decidim::ParticipatoryProcesses
  describe ProcessMCell, type: :cell do
    controller Decidim::ApplicationController

    subject { cell("decidim/participatory_processes/process_m", model).call }

    let(:model) { create(:participatory_process) }

    context "when rendering" do
      let(:show_space) { false }

      it "renders the card" do
        expect(subject).to have_css(".card--process")
      end

      it_behaves_like "space cell changes button text CTA"
    end
  end
end
