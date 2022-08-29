# frozen_string_literal: true

require "spec_helper"

describe Decidim::Votings::Census::Admin::GenerateAccessCodesJob do
  let(:dataset) { create(:dataset, status: :generating_codes) }
  let(:user) { create(:user, :admin, organization:) }
  let(:organization) { dataset&.organization || create(:organization) }

  describe "queue" do
    it "is queued to events" do
      expect(described_class.queue_name).to eq "default"
    end
  end

  describe "perform" do
    context "when the input is NOT valid" do
      context "when the dataset is missing" do
        let(:dataset) { nil }

        it "does not update the dataset nor the data" do
          expect(Decidim::Votings::Census::Admin::UpdateDataset).not_to receive(:call)

          described_class.perform_now(dataset, user)
        end
      end

      context "when the dataset is not in the correct status" do
        let(:dataset) { create(:dataset, status: :codes_generated) }

        it "does not update the dataset nor the data" do
          expect(Decidim::Votings::Census::Admin::UpdateDataset).not_to receive(:call)

          described_class.perform_now(dataset, user)
        end
      end

      context "when the user is missing" do
        let(:user) { nil }

        it "does not update the dataset nor the data" do
          expect(Decidim::Votings::Census::Admin::UpdateDataset).not_to receive(:call)

          described_class.perform_now(dataset, user)
        end
      end
    end

    context "when this input is valid" do
      let!(:data) { create_list(:datum, 5, dataset:) }

      it "generates the codes" do
        described_class.perform_now(dataset, user)

        data.each do |datum|
          datum.reload
          expect(datum.access_code.length).to be(8)
          expect(datum.hashed_online_data).not_to be_nil
        end
      end

      it "delegates the work to the command" do
        expect(Decidim::Votings::Census::Admin::UpdateDataset)
          .to receive(:call)
          .with(dataset, { status: :codes_generated }, user)

        described_class.perform_now(dataset, user)
      end

      it "updates the dataset status" do
        described_class.perform_now(dataset, user)

        expect(dataset.reload).to be_codes_generated
      end
    end
  end
end
