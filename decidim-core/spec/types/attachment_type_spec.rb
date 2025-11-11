# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Core
    describe AttachmentType do
      include_context "with a graphql class type"

      let(:model) { create(:attachment) }

      include_examples "timestamps interface"

      describe "content_type" do
        let(:query) { "{ contentType }" }

        it "returns the content type field" do
          expect(response["contentType"]).to eq(model.content_type)
        end
      end

      describe "description" do
        let(:query) { '{ description { translation(locale: "en")}}' }

        it "returns the description field" do
          expect(response["description"]["translation"]).to eq(translated(model.description))
        end
      end

      describe "file_size" do
        let(:query) { "{ fileSize }" }

        it "returns the file size field" do
          expect(response["fileSize"]).to eq(model.file_size)
        end
      end

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the id of this attachment" do
          expect(response).to eq("id" => model.id.to_s)
        end
      end

      describe "link" do
        let(:query) { "{ link }" }
        let(:model) { create(:attachment, :with_link) }

        it "returns the link field" do
          expect(response).to eq("link" => model.link)
        end

        context "when not available" do
          let(:model) { create(:attachment, :with_pdf) }

          it "returns nil" do
            expect(response).to eq("link" => nil)
          end
        end
      end

      describe "thumbnail" do
        let(:query) { "{ thumbnail }" }

        it "returns the thumbnail field" do
          expect(response).to eq("thumbnail" => model.thumbnail_url)
        end

        context "when not available" do
          let(:model) { create(:attachment, :with_pdf) }

          it "returns nil" do
            expect(response).to eq("thumbnail" => nil)
          end
        end
      end

      describe "title" do
        let(:query) { '{ title { translation(locale: "en")}}' }

        it "returns the title field" do
          expect(response["title"]["translation"]).to eq(translated(model.title))
        end
      end

      describe "type" do
        let(:query) { "{ type }" }

        it "returns the type field" do
          expect(response).to eq("type" => model.file_type)
        end
      end

      describe "url" do
        let(:query) { "{ url }" }

        it "returns the url field" do
          expect(response).to eq("url" => model.url)
        end
      end

      describe "weight" do
        let(:query) { "{ weight }" }

        it "returns the weight field" do
          expect(response).to eq("weight" => model.weight)
        end
      end
    end
  end
end
