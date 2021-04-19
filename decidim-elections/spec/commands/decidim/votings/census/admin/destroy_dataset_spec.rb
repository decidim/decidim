# frozen_string_literal: true

require "spec_helper"

module Decidim::Votings::Census::Admin
  describe DestroyDataset do
    subject { described_class.new(dataset, user) }

    let(:dataset) { create(:dataset) }
    let(:user) { create(:user, :admin, organization: dataset.voting.organization) }

    context "when everything is ok" do
      it "destroys the dataset" do
        subject.call

        expect { dataset.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with(:delete, dataset, user)
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
      end
    end
  end
end
