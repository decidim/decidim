# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ContentBlockRegistry do
    subject { described_class.new }

    describe "register" do
      it "registers a content block" do
        register_block(:my_scope, :my_block)

        expect(subject.for(:my_scope).map(&:name)).to eq [:my_block]
      end

      it "registers a content block with the same name in different scopes" do
        register_block(:my_scope, :my_block)

        expect { register_block(:another_scope, :my_block) }
          .not_to raise_error
      end

      it "raises an error if the content block is already registered" do
        register_block(:my_scope, :my_block)

        expect { register_block(:my_scope, :my_block) }
          .to raise_error(described_class::ContentBlockAlreadyRegistered)
      end
    end

    describe "for(:scope)" do
      it "returns all content blocks for that scope" do
        register_block(:homepage, :my_block)
        register_block(:another_page, :my_second_block)

        expect(subject.for(:homepage).map(&:name)).to eq [:my_block]
      end
    end

    def register_block(scope, name)
      subject.register(scope, name) do |content_block|
        content_block.cell "my/fake/cell"
        content_block.public_name_key "my.fake.key.name"
      end
    end
  end
end
