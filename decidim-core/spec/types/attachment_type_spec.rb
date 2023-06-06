# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Core
    describe AttachmentType do
      include_context "with a graphql class type"

      let(:title) { { en: "Participation guidelines", es: "Pautas de participación", ca: "Pautes de participació" } }
      let(:description) { { en: "Read through these guidelines carefully.", es: "Lea atentamente estas pautas.", ca: "Llegiu atentament aquestes directrius." } }
      let(:url) { "https://foo.bar/baz" }
      let(:file_type) { "image" }
      let(:thumbnail) { "https://foo.bar/baz.thumb" }

      let(:model) do
        double(title:, description:, url:, file_type:, thumbnail_url: thumbnail)
      end

      describe "title" do
        let(:query) { "{ title { translations { locale text } } }" }

        it "returns the attachment's url" do
          expect(response).to eq("title" => { "translations" => title.map { |locale, text| { "locale" => locale.to_s, "text" => text } } })
        end
      end

      describe "description" do
        let(:query) { "{ description { translations { locale text } } }" }

        it "returns the attachment's url" do
          expect(response).to eq("description" => { "translations" => description.map { |locale, text| { "locale" => locale.to_s, "text" => text } } })
        end
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
