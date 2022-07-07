# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ContentBlockManifest do
    subject { described_class.new(attributes) }

    let(:name) { :my_block }
    let(:cell) { "my/fake/cell" }
    let(:public_name_key) { "my.fake.key.name" }
    let(:attributes) do
      {
        name: name
      }
    end

    before do
      subject.cell = cell
      subject.public_name_key = public_name_key
    end

    it { is_expected.to be_valid }

    context "without a name" do
      let(:name) { nil }

      it { is_expected.not_to be_valid }
    end

    context "without a cell" do
      let(:cell) { nil }

      it { is_expected.not_to be_valid }
    end

    context "with repeated image names" do
      it "is not valid" do
        subject.images = [
          {
            name: :image,
            uploader: "Decidim::ImageUploader"
          },
          {
            name: :image,
            uploader: "Decidim::ImageUploader"
          }
        ]

        expect(subject).not_to be_valid
      end
    end

    context "with images without an uploader" do
      it "is not valid" do
        subject.images = [
          {
            name: :image
          }
        ]

        expect(subject).not_to be_valid
      end
    end

    describe "initializing via a block" do
      let(:attributes) { { name: name } }

      it "is valid" do
        setup = proc do |content_block|
          content_block.images = [
            {
              name: :image1,
              uploader: "Decidim::ImageUploader"
            },
            {
              name: :image2,
              uploader: "Decidim::ImageUploader"
            }
          ]

          content_block.cell = cell
        end

        setup.call(subject)

        expect(subject).to be_valid
        expect(subject.cell).to eq cell
        expect(subject.name).to eq name
        image_names = subject.images.pluck(:name)
        expect(image_names).to match_array [:image1, :image2]
      end
    end

    describe "when adding settings" do
      let(:attributes) { { name: name } }

      it "is valid" do
        setup = proc do |content_block|
          content_block.cell = cell
          content_block.settings_form_cell = "#{cell}_form"

          content_block.settings do |settings|
            settings.attribute :name, type: :text, translated: true, editor: true
          end
        end

        setup.call(subject)

        expect(subject).to be_valid
        expect(subject.settings.attributes).to have_key(:name)
        expect(subject.settings.attributes[:name].translated).to be true
        expect(subject.settings.attributes[:name].editor).to be true
        expect(subject.settings.attributes[:name].type).to eq :text
      end
    end
  end
end
