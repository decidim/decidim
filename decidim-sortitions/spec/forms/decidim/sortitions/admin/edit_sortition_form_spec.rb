# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Sortitions
    module Admin
      describe EditSortitionForm do
        subject { form }

        let(:organization) { build(:organization) }

        let(:title) do
          {
            en: "Title",
            es: "Título",
            ca: "Títol"
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
              title_en: title[:en],
              title_es: title[:es],
              title_ca: title[:ca],
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

        context "when no title" do
          let(:title) { { es: "", en: "", ca: "" } }

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
