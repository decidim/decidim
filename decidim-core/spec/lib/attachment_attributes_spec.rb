# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe AttachmentAttributes do
    let(:klass) do
      Class.new do
        def self.model_name
          ActiveModel::Name.new(self, nil, "dummy")
        end

        include ActiveModel::Model
        include Decidim::AttributeObject::Model
        include AttachmentAttributes
      end
    end

    let(:model) { klass.new }

    describe ".attachments_attribute do" do
      let(:photos) { create_list(:attachment, 10) }
      let(:photos_ids) { photos.map(&:id).map(&:to_s) }

      before do
        klass.class_eval do
          attachments_attribute :photos
        end
      end

      it "creates the photos and add_photos array arguments" do
        expect(klass.attribute_types["photos"]).to be_a(Decidim::Attributes::Array)
        expect(klass.attribute_types["photos"].value_type).to be(Integer)
        expect(klass.attribute_types["add_photos"]).to be_a(Decidim::Attributes::Array)
        expect(klass.attribute_types["add_photos"].value_type).to be(Object)
      end

      it "adds the argument reader method that converts the IDs to attachments" do
        model.photos = photos_ids
        expect(model.photos).to match_array(photos)
      end

      it "returns the original value if the original value is not an array" do
        model.photos = "test"
        expect(model.photos).to eq("test")
      end

      context "with two attachments attributes" do
        let(:documents) { create_list(:attachment, 10) }
        let(:documents_ids) { documents.map(&:id).map(&:to_s) }

        before do
          klass.class_eval do
            attachments_attribute :documents
          end
        end

        it "creates the documents and add_documents array arguments" do
          expect(klass.attribute_types["documents"]).to be_a(Decidim::Attributes::Array)
          expect(klass.attribute_types["documents"].value_type).to be(Integer)
          expect(klass.attribute_types["add_documents"]).to be_a(Decidim::Attributes::Array)
          expect(klass.attribute_types["add_documents"].value_type).to be(Object)
        end

        it "adds the argument reader method that converts the IDs to attachments" do
          model.photos = photos_ids
          expect(model.photos).to match_array(photos)

          model.documents = documents_ids
          expect(model.documents).to match_array(documents)
        end
      end
    end
  end
end
