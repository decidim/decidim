# frozen_string_literal: true

require "spec_helper"

describe Premailer::Adapter::Decidim do
  let(:document) { ::Nokogiri::HTML(document_template, nil, "UTF-8", &:recover) }
  let(:document_template) do
    <<~HTML
      <html>
      <head>
        <title>Test document</title>
      </head>
      <body>
        <div class="container">
          #{document_content}
        </div>
      </body>
      </html>
    HTML
  end
  let(:document_content) { "" }
  let(:utility_class) do
    adapter = described_class

    Class.new do
      include HtmlToPlainText
      include adapter

      def initialize(doc)
        @doc = doc
        @options = { line_length: 65 }
      end
    end
  end
  let(:utility) { utility_class.new(document) }

  describe "#to_plain_text" do
    let(:document_content) do
      <<~HTML
        <style>
        table.button table td {
          background: #f0f0f0 !important
        }
        </style>
        <p>This is a document with an inline style tag inside the content node.</p>
      HTML
    end

    it "strips out the style tags from the document" do
      expect(utility.to_plain_text).to eq("This is a document with an inline style tag inside the content\nnode.")
    end

    context "when the document is not wrapped within HTML body" do
      let(:document_template) { document_content }

      it "strips out the style tags from the document" do
        expect(utility.to_plain_text).to eq("This is a document with an inline style tag inside the content\nnode.")
      end
    end
  end
end
