# frozen_string_literal: true

require "spec_helper"

module Decidim::Votings::Census::Admin
  describe LaunchAccessCodesExport do
    subject { described_class.new(dataset, user) }

    let(:dataset) { create(:dataset, :codes_generated) }
    let(:user) { create(:user, :admin) }

    context "when the inputs are not valid" do
      context "when the user in nil" do
        let(:dataset) { create(:dataset) }
        let(:user) { nil }

        it { expect(subject).to broadcast(:invalid) }
      end

      context "when the dataset is not in the right status" do
        let(:dataset) { create(:dataset, status: :init_data) }

        it { expect(subject).to broadcast(:invalid) }
      end
    end

    context "when the inputs are valid" do
      let(:dataset) { create(:dataset, :codes_generated) }

      it "updates the data" do
        expect { subject.call }.to enqueue_job(ExportAccessCodesJob)
      end
    end
  end
end
