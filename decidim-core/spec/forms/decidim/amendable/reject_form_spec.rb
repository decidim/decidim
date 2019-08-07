# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Amendable
    describe RejectForm do
      subject { form }

      let(:params) do
        {
          id: 1
        }
      end

      let(:form) do
        described_class.from_params(params)
      end

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      context "when id is not present" do
        let(:params) do
          {
            id: nil
          }
        end

        it { is_expected.to be_invalid }
      end
    end
  end
end
