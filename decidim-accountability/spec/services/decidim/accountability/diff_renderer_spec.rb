# frozen_string_literal: true

require "spec_helper"

describe Decidim::Accountability::DiffRenderer, versioning: true do
  let!(:result) { create :result, progress: 50 }
  let(:version) { result.versions.last }

  before do
    Decidim.traceability.update!(
      result,
      "test suite",
      title: {
        en: "Only changes in English"
      },
      description: {
        ca: "<p>HTML description</p>"
      },
      progress: result.progress / 2.0,
      start_date: result.start_date + 1.day
    )
  end

  describe "#diff" do
    subject { described_class.new(version).diff }

    it "calculates the fields that have changed" do
      expect(subject.keys)
        .to match_array [:title_en, :description_ca, :progress, :start_date]
    end

    it "has the old and new values for each field" do
      expect(subject[:progress][:old_value]).to eq 50.0
      expect(subject[:progress][:new_value]).to eq 25.0
    end

    it "has the type of each field" do
      expected_types = {
        description_ca: :i18n_html,
        progress: :percentage,
        start_date: :date,
        title_en: :i18n
      }
      types = subject.to_h { |attribute, data| [attribute.to_sym, data[:type]] }
      expect(types).to eq expected_types
    end

    it "generates the labels correctly" do
      expected_labels = {
        description_ca: "Description (Català)",
        progress: "Progress",
        start_date: "Start date",
        title_en: "Title (English)"
      }
      labels = subject.to_h { |attribute, data| [attribute.to_sym, data[:label]] }
      expect(labels).to eq expected_labels
    end

    context "when one of the locales is not available" do
      let!(:default_available_locales) do
        I18n.available_locales
      end

      before do
        I18n.available_locales = [:en]
      end

      after do
        I18n.available_locales = default_available_locales
      end

      it "generates the label with locale name" do
        expected_labels = {
          description_ca: "Description (ca)",
          progress: "Progress",
          start_date: "Start date",
          title_en: "Title (English)"
        }
        labels = subject.to_h { |attribute, data| [attribute.to_sym, data[:label]] }
        expect(labels).to eq expected_labels
      end
    end
  end
end
