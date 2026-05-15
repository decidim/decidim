# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Core
    describe AttachmentCollectionType do
      include_context "with a graphql class type"

      let(:model) { create(:attachment_collection) }

      describe "name" do
        let(:query) { '{ name { translation(locale: "en")}}' }

        it "returns the name field" do
          expect(response["name"]["translation"]).to eq(translated(model.name))
        end
      end

      describe "attachments" do
        let(:query) { "{ attachments { id } }" }

        context "when the attachment collection has attachments" do
          let!(:attachment) { create(:attachment, :with_image, attachment_collection: model) }

          it "returns the attachment id field" do
            expect(response["attachments"]).to eq([{ "id" => attachment.id.to_s }])
          end
        end

        context "when the attachment collection does not have attachments" do
          let!(:attachment) { create(:attachment, :with_image) }

          it "returns the attachment id field" do
            expect(response["attachments"]).to be_empty
          end
        end
      end

      describe "description" do
        let(:query) { '{ description { translation(locale: "en")}}' }

        it "returns the description field" do
          expect(response["description"]["translation"]).to eq(translated(model.description))
        end
      end

      describe "weight" do
        let(:query) { "{ weight }" }

        it "returns the weight field" do
          expect(response).to eq("weight" => model.weight)
        end
      end

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the id field" do
          expect(response).to eq("id" => model.id.to_s)
        end
      end
    end
  end
end
