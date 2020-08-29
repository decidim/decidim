# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Map
    module Provider
      module Autocomplete
        describe Here::Builder do
          include_context "with dynamic map builder" do
            let(:options) { { apiKey: "key1234" } }
          end

          describe "#javascript_snippets" do
            it "returns the expected JavaScript assets" do
              expect(subject.javascript_snippets).to match(
                %r{<script src="/assets/decidim/geocoding/provider/here\.self-[^\.]*\.js\?body=1"></script>}
              )
              expect(subject.javascript_snippets).to match(
                %r{<script src="/assets/decidim/geocoding\.self-[^\.]*\.js\?body=1"></script>}
              )
            end
          end
        end
      end
    end
  end
end
