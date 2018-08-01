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
      subject.cell cell
      subject.public_name_key public_name_key
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

    context "with repeated images" do
      it "is not valid" do
        subject.image :image
        subject.image :image

        expect(subject).not_to be_valid
      end
    end

    context "with blank images" do
      it "raises an error" do
        expect { subject.image "" }
          .to raise_error(described_class::ImageNameCannotBeBlank)
      end
    end

    context "with repeated option names" do
      it "is not valid" do
        subject.option :my_option, :integer
        subject.option :my_option, :text

        expect(subject).not_to be_valid
      end
    end

    context "when registering an option without a name" do
      it "raises an error" do
        expect { subject.option "", :integer }
          .to raise_error(described_class::OptionNameCannotBeBlank)
      end
    end

    context "when registering an option without a type" do
      it "raises an error" do
        expect { subject.option :my_option, "" }
          .to raise_error(described_class::OptionTypeCannotBeBlank)
      end
    end

    describe "initializing via a block" do
      let(:attributes) { { name: name } }

      it "is valid" do
        setup = proc do |content_block|
          content_block.image :image_1
          content_block.image :image_2
          content_block.cell cell
        end

        setup.call(subject)
        expect(subject).to be_valid
        expect(subject.cell_name).to eq cell
        expect(subject.name).to eq name
        expect(subject.image_names).to match_array [:image_1, :image_2]
      end
    end
  end
end
