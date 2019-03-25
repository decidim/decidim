# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/space_cell_changes_button_text_cta"

module Decidim::ParticipatoryProcesses
  describe ProcessMCell, type: :cell do
    controller Decidim::ParticipatoryProcesses::ParticipatoryProcessesController

    let!(:participatory_process) { create(:participatory_process) }
    let(:model) { participatory_process }
    let(:cell_html) { cell("decidim/participatory_processes/process_m", participatory_process).call }

    context "when rendering" do
      let(:show_space) { false }

      it "renders the card" do
        expect(cell_html).to have_css(".card--process")
      end

      it_behaves_like "space cell changes button text CTA"
    end
  end
end
