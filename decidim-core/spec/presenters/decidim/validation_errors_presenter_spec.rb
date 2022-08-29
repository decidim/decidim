# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ValidationErrorsPresenter, type: :helper do
    let(:organization) { create(:organization) }
    let(:form) do
      double(
        valid?: valid,
        errors:
      )
    end
    let(:errors) do
      ActiveModel::Errors.new(organization).tap do |e|
        e.add(:name, "Error name detail 1")
        e.add(:name, "Error name detail 2")
        e.add(:host, "Error host detail")
      end
    end
    let(:error_message) { "Generic error message" }

    describe "#message" do
      subject { described_class.new(error_message, form).message }

      context "when valid" do
        let(:valid) { true }

        it { is_expected.to include(error_message) }
        it { is_expected.not_to include("detail") }
      end

      context "when invalid" do
        let(:valid) { false }

        it { is_expected.to include(error_message) }
        it { is_expected.to include("<li>Name Error name detail 1</li>") }
        it { is_expected.to include("<li>Name Error name detail 2</li>") }
        it { is_expected.to include("<li>Host Error host detail</li>") }
      end
    end
  end
end
