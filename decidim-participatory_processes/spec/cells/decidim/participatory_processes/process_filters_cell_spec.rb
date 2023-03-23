# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatoryProcesses
  describe ProcessFiltersCell, type: :cell do
    let(:organization1) { create(:organization) }
    let(:organization2) { create(:organization) }

    let!(:participatory_process_list1) { create_list(:participatory_process, 2, :published, organization: organization1) }
    let!(:participatory_process_list2) { create_list(:participatory_process, 2, :published, organization: organization2) }

    subject { cell("decidim/participatory_processes/process_filters", default_filter: "active") }
    controller Decidim::ParticipatoryProcesses::ParticipatoryProcessesController

    before do
      allow(controller).to receive(:current_organization).and_return(organization1)
      allow(subject).to receive(:controller).and_return(controller)
      allow(subject).to receive(:params).and_return(ActionController::Parameters.new({ filter: { with_date: "all" } }))
    end

    it "counts the processes" do
      expect(subject.filtered_processes("all", filter_with_type: false).count).to eq(2)
    end
  end
end
