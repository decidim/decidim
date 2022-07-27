# frozen_string_literal: true

require "spec_helper"

module Decidim::Votings::Census::Admin
  describe CreateDataset do
    subject { described_class.new(form, user) }

    let(:voting) { create(:voting) }
    let(:user) { create(:user, :admin, organization: voting.organization) }
    let(:file) { upload_test_file(Decidim::Dev.test_file("import_voting_census.csv", "text/csv")) }
    let(:params) { { file: } }
    let(:context) { { current_participatory_space: voting } }

    let(:form) { DatasetForm.from_params(params).with_context(context) }

    context "when the form is not valid" do
      let(:file) { nil }

      it "broadcasts invalid" do
        expect(subject.call).to broadcast(:invalid)
      end

      it "does not enqueue any job" do
        expect(CreateDatumJob).not_to receive(:perform_later)

        subject.call
      end
    end

    context "when headers are invalid" do
      let(:file) { upload_test_file(Decidim::Dev.test_file("import_voting_census_without_headers.csv", "text/csv")) }

      it "broadcasts invalid_csv_file" do
        expect(subject.call).to broadcast(:invalid_csv_header)
      end

      it "does not enqueue any job" do
        expect(CreateDatumJob).not_to receive(:perform_later)

        subject.call
      end
    end

    context "when file only contains headers" do
      let(:file) { upload_test_file(Decidim::Dev.test_file("import_voting_census_only_headers.csv", "text/csv")) }

      it "broadcasts invalid_csv_file" do
        expect(subject.call).to broadcast(:invalid_csv_header)
      end

      it "does not enqueue any job" do
        expect(CreateDatumJob).not_to receive(:perform_later)

        subject.call
      end
    end

    it "broadcasts ok" do
      expect(subject.call).to broadcast(:ok)
      expect(Decidim::Votings::Census::Dataset.last.csv_row_raw_count).to eq(5)
    end

    context "when active storage service is not local" do
      before do
        allow(ActiveStorage::Blob.service).to receive(:respond_to?).and_call_original
        # rubocop:disable RSpec/StubbedMock
        expect(ActiveStorage::Blob.service).to receive(:respond_to?).with(:path_for).and_return(false)
        # rubocop:enable RSpec/StubbedMock
      end

      it "still broadcasts ok" do
        expect(subject.call).to broadcast(:ok)
      end
    end

    it "enqueues a job for processing the dataset and strips the data from whitespaces" do
      expect { subject.call }.to(have_enqueued_job(CreateDatumJob).at_least(1).times.with do |_user, _dataset, row|
        expect(row[3]).to eq("Hugo Doe") if row.first == "55566677B"
      end)
    end

    it "enqueues a job for processing the dataset" do
      expect { subject.call }.to enqueue_job(CreateDatumJob).exactly(5).times
    end

    it "traces the action", versioning: true do
      expect(Decidim.traceability)
        .to receive(:create)
        .with(
          Decidim::Votings::Census::Dataset,
          user,
          kind_of(Hash),
          visibility: "admin-only"
        )
        .and_call_original

      expect { subject.call }.to change(Decidim::ActionLog, :count)
      action_log = Decidim::ActionLog.where(resource_type: "Decidim::Votings::Census::Dataset").last
      expect(action_log.version).to be_present
      expect(action_log.version.event).to eq "create"
    end
  end
end
