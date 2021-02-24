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
        include Virtus.model
        include AttachmentAttributes
      end
    end

    let(:model) { klass.new }

    describe ".attachments_attribute do" do
      let(:attachments) { create_list(:attachment, 10) }
      let(:attachment_ids) { attachments.map(&:id).map(&:to_s) }

      before do
        klass.class_eval do
          attachments_attribute :photos
        end
      end

      it "creates the photos and add_photos array arguments" do
        expect(klass.attribute_set[:photos].type.primitive).to be(Array)
        expect(klass.attribute_set[:photos].type.member_type.primitive).to be(String)
        expect(klass.attribute_set[:add_photos].type.primitive).to be(Array)
        expect(klass.attribute_set[:add_photos].type.member_type.primitive).to be(BasicObject)
      end

      it "adds the argument reader method that converts the IDs to attachments" do
        model.photos = attachment_ids
        expect(model.photos).to match_array(attachments)
      end

      it "returns the original value if the original value is not an array" do
        model.instance_variable_set(:@photos, "test")
        expect(model.photos).to eq("test")
      end
    end
  end
end
