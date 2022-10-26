# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe Markdown do
      subject { markdown }

      let(:markdown) { Decidim::Comments::Markdown.new }

      describe "#render" do
        subject { markdown.render(text) }

        context "with underscores" do
          let(:text) { "Look for comment_maximum_length in the code." }

          it "does not replace the underscores" do
            expect(subject).to eq("<p>#{text}</p>")
          end
        end

        context "with underscore links" do
          let(:text) { "Check out https://decidim.org/democracy_for_everyone for more information." }

          it "does not replace the underscores" do
            expect(subject).to eq(%(<p>#{text}</p>))
          end
        end
      end
    end
  end
end
