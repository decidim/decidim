# frozen_string_literal: true

require "spec_helper"

module Decidim::Votings::Census::Admin
  describe GenerateAccessCodes do
    subject { described_class.new(dataset, user) }

    let(:dataset) { create(:dataset, organization: user.organization) }
    let(:user) { create(:user, :admin) }

    context "when the inputs are not valid" do
      context "when the user in nil" do
        let(:dataset) { create(:dataset) }
        let(:user) {}

        it { expect(subject.call).to broadcast(:invalid) }
      end

      context "when the is no datum in the dataset" do
        let(:data) { [] }

        it { expect(subject.call).to broadcast(:invalid) }
      end
    end

    context "when the inputs are valid" do
      let!(:data) { create_list(:datum, 5, dataset: dataset) }

      it "updates the data" do
        expect(subject.call).to broadcast(:ok)

        data.each do |datum|
          datum.reload
          expect(datum.access_code.length).to be(8)
          expect(datum.hashed_online_data).not_to be_nil
        end
      end
    end
  end
end
