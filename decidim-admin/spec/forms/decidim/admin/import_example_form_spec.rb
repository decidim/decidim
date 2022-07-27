# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe ImportExampleForm do
      subject { form }

      let(:organization) { create(:organization) }
      let!(:component) { create(:dummy_component, organization:) }
      let(:user) { create(:user, :confirmed, :admin, organization:) }
      let(:file) { Decidim::Dev.test_file("import_proposals.csv", "text/csv") }
      let(:name) { "dummies" }
      let(:format) { "csv" }

      let(:params) { { name:, format: } }

      let(:form) do
        described_class.from_params(params).with_context(
          current_organization: organization,
          current_component: component
        )
      end

      context "when everything is OK" do
        it { is_expected.to be_valid }

        context "with JSON format" do
          let(:format) { "json" }

          it { is_expected.to be_valid }
        end

        context "with XLSX format" do
          let(:format) { "xlsx" }

          it { is_expected.to be_valid }
        end
      end

      context "when manifest name is unknown" do
        let(:name) { "unknown" }

        it { is_expected.not_to be_valid }
      end

      context "when format is unknown" do
        let(:format) { "xls" }

        it { is_expected.not_to be_valid }
      end

      describe "#example" do
        it "returns the example data" do
          locales = component.organization.available_locales

          expect(subject.example.read).to eq(
            [
              locales.map { |l| "title/#{l}" } + %w(body) + locales.map { |l| "translatable_text/#{l}" } + %w(address latitude longitude),
              locales.map { "Title text" } + ["Body text"] + locales.map { "Translatable text" } + ["Fake street 1", 1.0, 1.0]
            ].map { |row| row.join(";") }.join("\n").concat("\n")
          )
        end
      end
    end
  end
end
