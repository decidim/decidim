# frozen_string_literal: true

require "spec_helper"

module Decidim::Votings::Census::Admin
  describe IncrementDatasetProcessedRows do
    subject { described_class.new(dataset) }

    let!(:dataset) { create(:dataset, csv_row_processed_count: 0, status: "creating_data") }

    context "when everything is ok" do
      it "increments the processed rows" do
        expect { subject.call }.to change(dataset, :csv_row_processed_count).from(0).to(1)
      end

      it "changes the dataset status" do
        expect { subject.call }.to change(dataset, :status).from("creating_data").to("data_created")
      end
    end
  end
end
