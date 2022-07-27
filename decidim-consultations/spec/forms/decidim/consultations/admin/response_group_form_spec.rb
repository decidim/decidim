# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Consultations
    module Admin
      describe ResponseGroupForm do
        subject do
          described_class
            .from_params(attributes)
            .with_context(
              current_organization: question.organization,
              current_question: question
            )
        end

        let(:organization) { create :organization }
        let(:consultation) { create :consultation, organization: }
        let(:question) { create :question }
        let(:title) do
          {
            en: "Title",
            es: "Título",
            ca: "Títol"
          }
        end
        let(:attributes) do
          {
            "response_group" => {
              "title_en" => title[:en],
              "title_es" => title[:es],
              "title_ca" => title[:ca]
            }
          }
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when default language in title is missing" do
          let(:title) do
            { ca: "Títol" }
          end

          it { is_expected.to be_invalid }
        end
      end
    end
  end
end
