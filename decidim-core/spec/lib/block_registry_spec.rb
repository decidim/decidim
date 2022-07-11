# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe BlockRegistry do
    subject { BlockRegistry.new }

    let(:foo_block) { ->(n) { n.foo } }
    let(:bar_block) { ->(n) { n.bar } }

    describe "#register" do
      it "registers the provided block" do
        subject.register(:foo, &foo_block)
        expect(subject.registrations[:foo]).to be(foo_block)
      end

      context "when a block is not provided" do
        it "does not register anything" do
          subject.register(:foo)
          expect(subject.registrations[:foo]).to be_nil
        end
      end
    end

    describe "#registrations" do
      let(:foo_argument) { double }

      before do
        subject.register(:foo, &foo_block)
        subject.register(:bar, &bar_block)
      end

      it "returns the registered blocks" do
        expect(subject.registrations).to eq(
          foo: foo_block,
          bar: bar_block
        )
      end

      it "calls the correct block" do
        expect(foo_argument).to receive(:foo)

        subject.registrations[:foo].call(foo_argument)
      end
    end
  end
end
