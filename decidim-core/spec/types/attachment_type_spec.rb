# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Core
    describe AttachmentType do
      include_context "with a graphql class type"

      let(:model) { create(:attachment) }

      include_examples "timestamps interface"

      describe "title" do
        let(:query) { '{ title { translation(locale: "en")}}' }

        it "returns the attachment's title" do
          expect(response["title"]["translation"]).to eq(translated(model.title))
        end
      end

      describe "description" do
        let(:query) { '{ description { translation(locale: "en")}}' }

        it "returns the attachment's description" do
          expect(response["description"]["translation"]).to eq(translated(model.description))
        end
      end

      describe "url" do
        let(:query) { "{ url }" }

        it "returns the attachment's url" do
          expect(response).to eq("url" => model.url)
        end
      end

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the attachment's id" do
          expect(response).to eq("id" => model.id.to_s)
        end
      end

      describe "weight" do
        let(:query) { "{ weight }" }

        it "returns the attachment's weight" do
          expect(response).to eq("weight" => model.weight.to_s)
        end
      end

      describe "type" do
        let(:query) { "{ type }" }

        it "returns the attachment's type" do
          expect(response).to eq("type" => model.file_type)
        end
      end

      describe "thumbnail" do
        let(:query) { "{ thumbnail }" }

        it "returns the attachment's thumbnail" do
          expect(response).to eq("thumbnail" => model.thumbnail_url)
        end

        context "when not available" do
          let(:model) { create(:attachment, :with_pdf) }

          it "returns nil" do
            expect(response).to eq("thumbnail" => nil)
          end
        end
      end

      describe "link" do
        let(:query) { "{ link }" }
        let(:model) { create(:attachment, :with_link) }

        it "returns the attachment's link" do
          expect(response).to eq("link" => model.link)
        end

        context "when not available" do
          let(:model) { create(:attachment, :with_pdf) }

          it "returns nil" do
            expect(response).to eq("link" => nil)
          end
        end
      end
    end
  end
end
