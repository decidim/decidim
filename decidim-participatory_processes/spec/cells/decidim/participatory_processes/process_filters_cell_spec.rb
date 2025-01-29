# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatoryProcesses
  describe ProcessFiltersCell, type: :cell do
    let(:organization1) { create(:organization) }
    let(:organization2) { create(:organization) }

    let!(:participatory_process_list1) { create_list(:participatory_process, 2, :published, organization: organization1) }
    let!(:participatory_process_list2) { create_list(:participatory_process, 2, :published, organization: organization2) }

    let(:my_cell) { cell("decidim/participatory_processes/process_filters", default_filter:) }
    let(:default_filter) { "active" }
    let(:filter_params) { { with_date: "all" } }

    subject { my_cell }
    controller Decidim::ParticipatoryProcesses::ParticipatoryProcessesController

    before do
      allow(controller).to receive(:current_organization).and_return(organization1)
      allow(my_cell).to receive(:controller).and_return(controller)
      allow(my_cell).to receive(:params).and_return(ActionController::Parameters.new({ filter: filter_params }))
    end

    it "counts the processes" do
      expect(subject.filtered_processes("all").count).to eq(2)
    end

    describe "#current_filter" do
      subject { my_cell.current_filter }

      let(:filter_params) { { with_date: date_filter } }

      shared_examples "expected current_filter value" do |given_value|
        let(:date_filter) { given_value }

        it { is_expected.to eq(given_value) }
      end

      shared_examples "unexpected current_filter_value" do |given_value|
        let(:date_filter) { given_value }

        it { is_expected.to eq(default_filter) }
      end

      it_behaves_like "expected current_filter value", "active"
      it_behaves_like "expected current_filter value", "upcoming"
      it_behaves_like "expected current_filter value", "past"
      it_behaves_like "expected current_filter value", "all"

      it_behaves_like "unexpected current_filter_value", nil
      it_behaves_like "unexpected current_filter_value", ["upcoming"]
      it_behaves_like "unexpected current_filter_value", { 1 => "upcoming" }
      it_behaves_like "unexpected current_filter_value", "unknown"
      it_behaves_like "unexpected current_filter_value", "upcomingfoobar"
      it_behaves_like "unexpected current_filter_value", "upcoming foobar"
    end
  end
end
