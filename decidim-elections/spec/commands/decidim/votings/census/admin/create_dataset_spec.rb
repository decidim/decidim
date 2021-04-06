# frozen_string_literal: true

require "spec_helper"

module Decidim::Votings::Census::Admin
  describe CreateDataset do
    subject { described_class.new(form, user) }

    let(:voting) { create(:voting) }
    let(:user) { create(:user, :admin, organization: voting.organization) }
    let(:file) { Decidim::Dev.test_file("import_voting_census.csv", "text/csv") }
    let(:params) { { file: file } }
    let(:context) { { current_participatory_space: voting } }

    let(:form) { DatasetForm.from_params(params).with_context(context) }

    context "when the form is not valid" do
      let(:file) {}

      it "broadcasts invalid" do
        expect(subject.call).to broadcast(:invalid)
      end

      it "does not enqueue any job" do
        expect(CreateDatumJob).not_to receive(:perform_later)

        subject.call
      end
    end

    it "broadcasts ok" do
      expect(subject.call).to broadcast(:ok)
    end

    it "enqueues a job for processing the dataset" do
      expect { subject.call }.to enqueue_job(CreateDatumJob).at_least(4).times
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
