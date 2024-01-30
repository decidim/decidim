# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Exporters do
    describe ".find_exporter" do
      subject { described_class.find_exporter(format) }

      described_class::EXPORT_FORMATS.each do |format|
        let(:format) { format }

        context "with the #{format} format" do
          subject { described_class.find_exporter(format) }

          it "returns the correct exporter" do
            expect(subject).to eq(described_class.const_get(format))
          end
        end
      end

      context "with an unknown format" do
        let(:format) { "XYZ" }

        it "raises an UnknownFormatError" do
          expect { subject }.to raise_error(described_class::UnknownFormatError)
        end
      end

      context "with nil format" do
        let(:format) { nil }

        it "raises an UnknownFormatError" do
          expect { subject }.to raise_error(described_class::UnknownFormatError)
        end
      end
    end
  end
end
