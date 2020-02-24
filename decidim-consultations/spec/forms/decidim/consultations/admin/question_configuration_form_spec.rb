# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Consultations
    module Admin
      describe QuestionConfigurationForm do
        subject do
          described_class
            .from_params(attributes)
            .with_context(
              current_organization: question.organization,
              current_question: question
            )
        end

        let(:organization) { create :organization }
        let(:question) { create :question }
        let(:info) do
          {
            en: "Information",
            es: "Información",
            ca: "Informació"
          }
        end
        let(:min_votes) { 4 }
        let(:max_votes) { 4 }
        let(:attributes) do
          {
            "question" => {
              "min_votes" => min_votes,
              "max_votes" => max_votes,
              "title_en" => info[:en],
              "title_es" => info[:es],
              "title_ca" => info[:ca]
            }
          }
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when no information specified" do
          let(:info) { { en: nil, ca: nil, es: nil } }

          it { is_expected.to be_valid }
        end

        context "when min_votes are higher than max_votes" do
          let(:min_votes) { 5 }

          it { is_expected.to be_invalid }
        end

        context "when min_votes is lower than 1" do
          let(:min_votes) { 0 }

          it { is_expected.to be_invalid }
        end

        context "when max_votes is lower than 1" do
          let(:min_votes) { 0 }
          let(:max_votes) { 0 }

          it { is_expected.to be_invalid }
        end
      end
    end
  end
end
