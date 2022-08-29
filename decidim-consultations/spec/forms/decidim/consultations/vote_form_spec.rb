# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Consultations
    describe VoteForm do
      subject { described_class.from_params(attributes) }

      let(:response) { create :response }
      let(:decidim_consultations_response_id) { response.id }
      let(:attributes) do
        {
          decidim_consultations_response_id:
        }
      end

      it { is_expected.to be_valid }

      context "when decidim_consultations_response_id is nil" do
        let(:decidim_consultations_response_id) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when decidim_consultations_response_id points to non existing question" do
        let(:decidim_consultations_response_id) { 999_999_999 }

        it { is_expected.not_to be_valid }

        it "Returns a message error" do
          subject.validate
          expect(subject.errors[:decidim_consultations_response_id]).to include("Response not found.")
        end
      end
    end
  end
end
