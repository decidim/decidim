# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Core
    describe AttachmentType do
      include_context "with a graphql class type"

      let(:url) { "https://foo.bar/baz" }
      let(:file_type) { "image" }
      let(:thumbnail) { "https://foo.bar/baz.thumb" }

      let(:model) do
        double(url:, file_type:, thumbnail_url: thumbnail)
      end

      describe "url" do
        let(:query) { "{ url }" }

        it "returns the attachment's url" do
          expect(response).to eq("url" => url)
        end
      end

      describe "type" do
        let(:query) { "{ type }" }

        it "returns the attachment's type" do
          expect(response).to eq("type" => file_type)
        end
      end

      describe "thumbnail" do
        let(:query) { "{ thumbnail }" }

        it "returns the attachment's thumbnail" do
          expect(response).to eq("thumbnail" => thumbnail)
        end

        context "when not available" do
          let(:thumbnail) { nil }

          it "returns nil" do
            expect(response).to eq("thumbnail" => nil)
          end
        end
      end
    end
  end
end
