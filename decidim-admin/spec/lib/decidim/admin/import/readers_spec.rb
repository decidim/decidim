# frozen_string_literal: true

require "spec_helper"

describe Decidim::Admin::Import::Readers do
  describe ".search_by_file_extension" do
    it "finds the reader for a lowercase extension" do
      expect(described_class.search_by_file_extension("csv")).to eq(Decidim::Admin::Import::Readers::CSV)
    end

    it "finds the reader for an uppercase extension" do
      expect(described_class.search_by_file_extension("CSV")).to eq(Decidim::Admin::Import::Readers::CSV)
    end

    it "finds the reader for a mixed case extension" do
      expect(described_class.search_by_file_extension("Xlsx")).to eq(Decidim::Admin::Import::Readers::XLSX)
    end

    it "returns nil for an extension without a reader" do
      expect(described_class.search_by_file_extension("pdf")).to be_nil
    end

    it "returns nil for a blank extension" do
      expect(described_class.search_by_file_extension(nil)).to be_nil
    end
  end

  describe ".search_by_mime_type" do
    it "finds the reader for a known mime type" do
      expect(described_class.search_by_mime_type(Decidim::Admin::Import::Readers::CSV::MIME_TYPE)).to eq(
        Decidim::Admin::Import::Readers::CSV
      )
    end

    it "returns nil for an unknown mime type" do
      expect(described_class.search_by_mime_type("application/pdf")).to be_nil
    end
  end
end
