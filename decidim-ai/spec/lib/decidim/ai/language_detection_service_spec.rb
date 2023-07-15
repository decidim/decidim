# frozen_string_literal: true

require "spec_helper"

describe Decidim::Ai::LanguageDetectionService do
  subject { described_class.new(text) }

  shared_examples "properly detects language" do |text, language|
    let(:text) { text }

    it "returns #{language}" do
      expect(subject.language_code).to eq(language)
    end
  end

  it_behaves_like "properly detects language", "This is a test", "en"
  it_behaves_like "properly detects language", "Aceasta este o propozitie", "ro"
end
