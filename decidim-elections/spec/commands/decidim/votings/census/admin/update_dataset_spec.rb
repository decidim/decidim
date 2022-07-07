# frozen_string_literal: true

require "spec_helper"

module Decidim::Votings::Census::Admin
  describe UpdateDataset do
    subject { described_class.new(dataset, attributes, user) }

    let(:dataset) { create(:dataset, status: "init_data") }
    let(:user) { create(:user, :admin, organization: organization) }
    let(:organization) { dataset&.organization || create(:organization) }
    let(:attributes) { { status: :data_created } }

    context "when the inputs are NOT valid" do
      context "when the user is nil" do
        let(:dataset) { create(:dataset) }
        let(:user) { nil }

        it "broadcasts invalid" do
          expect(subject.call).to broadcast(:invalid)
        end
      end

      context "when the dataset is nil" do
        let(:dataset) { nil }

        it "broadcasts invalid" do
          expect(subject.call).to broadcast(:invalid)
        end
      end

      context "when there is no attribute" do
        let(:attributes) { {} }

        it "broadcasts invalid" do
          expect(subject.call).to broadcast(:invalid)
        end
      end
    end

    context "when the inputs are valid" do
      it "updates the dataset" do
        expect(subject.call).to broadcast(:ok)
        expect(dataset.reload.status).to match("data_created")
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:update!)
          .with(
            dataset,
            user,
            attributes
          )
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.where(resource_type: "Decidim::Votings::Census::Dataset").last
        expect(action_log.version).to be_present
        expect(action_log.version.event).to eq "update"
      end
    end
  end
end
