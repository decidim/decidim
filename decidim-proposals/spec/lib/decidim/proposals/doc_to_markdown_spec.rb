# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe DocToMarkdown do

      context "from libreoffice odt file" do
        it "transforms into markdown" do
          file= IO.read(Decidim::Dev.asset("participatory_text.odt"))
          transformer= DocToMarkdown.new(file)

          expected= IO.read(Decidim::Dev.asset("participatory_text.md"))
          puts ">>>>>>>>>>>>>>>>>>>>>"
          puts transformer.to_md
          puts "<<<<<<<<<<<<<<<<<<<<<"
          expect(transformer.to_md).to eq(expected)
        end
      end

    end
  end
end
