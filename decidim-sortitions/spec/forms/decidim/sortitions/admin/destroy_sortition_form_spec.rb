# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Sortitions
    module Admin
      describe DestroySortitionForm do
        subject { form }

        let(:organization) { build(:organization) }

        let(:cancel_reason) do
          {
            en: "Cancel reason",
            es: "Motivo de la cancelación",
            ca: "Motiu de la cancelació"
          }
        end
        let(:params) do
          {
            sortition: {
              cancel_reason_en: cancel_reason[:en],
              cancel_reason_es: cancel_reason[:es],
              cancel_reason_ca: cancel_reason[:ca]
            }
          }
        end

        let(:form) { described_class.from_params(params).with_context(current_organization: organization) }

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when no cancel_reason" do
          let(:cancel_reason) { { es: "", en: "", ca: "" } }

          it { is_expected.to be_invalid }
        end
      end
    end
  end
end
