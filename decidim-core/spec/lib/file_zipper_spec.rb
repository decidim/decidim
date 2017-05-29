# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe FileZipper do
    subject { FileZipper.new("foo.txt", "bar") }

    describe "#zip" do
      let(:zip) { subject.zip }

      it "zips a file" do
        entries = []

        Zip::InputStream.open(StringIO.new(zip)) do |io|
          while (entry = io.get_next_entry)
            entries << { name: entry.name, content: entry.get_input_stream.read }
          end
        end

        expect(entries.length).to eq(1)

        entry = entries.first
        expect(entry[:name]).to eq("foo.txt")
        expect(entry[:content]).to eq("bar")
      end
    end
  end
end
