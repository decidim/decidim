# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe IoEncoder do
    let(:input) { File.read(Decidim::Dev.asset(file_name)) }

    describe "to_standard_encoding" do
      context "when input is in utf-8" do
        let(:file_name) { "participatory_text.md" }

        it "keeps the same encoding" do
          expect(IoEncoder.to_standard_encoding(input).encoding).to eq(Encoding::UTF_8)
        end
      end

      context "when input is in ascii-8bits" do
        let(:file_name) { "participatory_text.md" }

        it "is transformed to utf-8 encoding" do
          inn = input.force_encoding(Encoding::ASCII_8BIT)
          expect(IoEncoder.to_standard_encoding(inn).encoding).to eq(Encoding::UTF_8)
        end
      end

      context "when input is in iso-8859-15" do
        let(:file_name) { "iso-8859-15.md" }

        it "is transformed to utf-8 encoding" do
          expect(IoEncoder.to_standard_encoding(input).encoding).to eq(Encoding::UTF_8)
        end
      end

      context "when input is in binary" do
        let(:file_name) { "participatory_text.odt" }

        it "keeps it unchanged" do
          expect(IoEncoder.to_standard_encoding(input)).to eq(input)
        end
      end
    end
  end
end
