# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Votings
    module Admin
      describe BallotStyleForm do
        subject(:form) { described_class.from_params(attributes).with_context(context) }

        let(:voting) { create(:voting) }
        let(:context) { { voting: } }
        let(:code) { ::Faker::Lorem.word }
        let(:question_ids) { [1, 2, 4, 5] }

        let(:attributes) do
          {
            code:,
            question_ids:
          }
        end

        it { is_expected.to be_valid }

        describe "when the code is missing" do
          let(:code) { nil }

          it { is_expected.not_to be_valid }
        end

        describe "when the code is lowercase" do
          it { expect(subject.code).to eq(code.upcase) }
        end
      end
    end
  end
end
