# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Votings
    module Admin
      describe BallotStyleForm do
        subject(:form) { described_class.from_params(attributes).with_context(context) }

        let(:voting) { create(:voting) }
        let(:context) { { voting: voting } }
        let(:title) { ::Faker::Lorem.word }
        let(:code) { ::Faker::Lorem.word }
        let(:question_ids) { [1, 2, 4, 5] }

        let(:attributes) do
          {
            title: title,
            code: code,
            question_ids: question_ids
          }
        end

        it { is_expected.to be_valid }

        describe "when th code is missing" do
          let(:code) { nil }

          it { is_expected.not_to be_valid }
        end

        describe "when the code is already in use in the voting" do
          let!(:other_ballot_style) { create(:ballot_style, code: code, voting: voting) }

          it { is_expected.not_to be_valid }
        end

        describe "when the code is already in use in another voting" do
          let!(:other_ballot_style) { create(:ballot_style, code: code) }

          it { is_expected.to be_valid }
        end
      end
    end
  end
end
