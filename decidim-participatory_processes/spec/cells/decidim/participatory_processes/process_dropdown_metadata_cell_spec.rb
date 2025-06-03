# frozen_string_literal: true

require "spec_helper"

require "decidim/core/test/shared_examples/participatory_space_dropdown_metadata_cell_examples"

module Decidim::ParticipatoryProcesses
  describe ProcessDropdownMetadataCell, type: :cell do
    controller Decidim::ApplicationController

    subject { cell("decidim/participatory_processes/process_dropdown_metadata", model).call }

    let(:model) { create(:participatory_process, :with_steps) }

    it "renders the current step title" do
      expect(subject).to have_content "Current phase"
      expect(subject).to have_content translated(model.active_step.title)
    end

    include_examples "participatory space dropdown metadata cell"
    include_examples "participatory space dropdown metadata cell hashtag"
  end
end
