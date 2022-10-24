# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Sortitions
    module Admin
      describe SortitionForm do
        subject { form }

        let(:organization) { build(:organization) }

        let(:decidim_proposals_component_id) { ::Faker::Number.number(digits: 10) }
        let(:decidim_category_id) { ::Faker::Number.number(digits: 10) }
        let(:dice) { ::Faker::Number.between(from: 1, to: 6) }
        let(:target_items) { ::Faker::Number.number(digits: 2) }
        let(:title) do
          {
            en: "Title",
            es: "Título",
            ca: "Títol"
          }
        end
        let(:witnesses) do
          {
            en: "Witnesses",
            es: "Testigos",
            ca: "Testimonis"
          }
        end
        let(:additional_info) do
          {
            en: "Additional info",
            es: "Información adicional",
            ca: "Informació adicional"
          }
        end
        let(:params) do
          {
            sortition: {
              decidim_proposals_component_id:,
              decidim_category_id:,
              dice:,
              target_items:,
              title_en: title[:en],
              title_es: title[:es],
              title_ca: title[:ca],
              witnesses_en: witnesses[:en],
              witnesses_es: witnesses[:es],
              witnesses_ca: witnesses[:ca],
              additional_info_en: additional_info[:en],
              additional_info_es: additional_info[:es],
              additional_info_ca: additional_info[:ca]
            }
          }
        end

        let(:form) { described_class.from_params(params).with_context(current_organization: organization) }

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when there is no proposals component selected" do
          let(:decidim_proposals_component_id) { nil }

          it { is_expected.to be_invalid }
        end

        context "when there is no category selected" do
          let(:decidim_category_id) { nil }

          it { is_expected.to be_valid }
        end

        context "when there is no dice value selected" do
          let(:dice) { nil }

          it { is_expected.to be_invalid }
        end

        context "when dice value is invalid" do
          let(:dice) { "7" }

          it { is_expected.to be_invalid }
        end

        context "when there is no target items value selected" do
          let(:target_items) { nil }

          it { is_expected.to be_invalid }
        end

        context "when target items value is invalid" do
          let(:target_items) { "0" }

          it { is_expected.to be_invalid }
        end

        context "when no title" do
          let(:title) { { es: "", en: "", ca: "" } }

          it { is_expected.to be_invalid }
        end

        context "when no witnesses" do
          let(:witnesses) { { es: "", en: "", ca: "" } }

          it { is_expected.to be_invalid }
        end

        context "when no additional info" do
          let(:additional_info) { { es: "", en: "", ca: "" } }

          it { is_expected.to be_invalid }
        end
      end
    end
  end
end
