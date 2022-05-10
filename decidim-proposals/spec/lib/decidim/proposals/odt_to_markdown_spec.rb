# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe OdtToMarkdown do
      context "when libreoffice odt file" do
        it "transforms into markdown" do
          file = File.read(Decidim::Dev.asset("participatory_text.odt"))
          transformer = DocToMarkdown.new(file, DocToMarkdown::ODT_MIME_TYPE)

          expected = File.read(Decidim::Dev.asset("participatory_text.md"))
          expected.strip!
          # doc2text does not support ordered lists use - instead
          expected.gsub!(/^\d\. /, "- ")
          # doc2text can not embed images, instead leaves the title, expect this
          expected.gsub!(/^![^\n]+\n/, "Decidim Logo\n")

          actual = transformer.to_md
          actual.strip!
          # doc2text use '*' for lists, use '-' as expected
          actual.gsub!(/^\* /, "- ")
          # doc2text leaves a lot off blank lines, compact them
          actual.gsub!(/\n{3,}/, "\n\n")

          expect(actual).to eq(expected)
        end
      end
    end
  end
end
