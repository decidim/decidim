# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Importers::ImportManifest do
    subject { described_class.new(name, manifest) }

    let(:manifest) { Decidim::ComponentManifest.new }
    let(:name) { "bar" }

    describe "#name" do
      it "returns the symbolized initialization name" do
        expect(subject.name).to eq(:bar)
      end
    end

    describe "#manifest" do
      it "returns the parent manifest" do
        expect(subject.manifest).to eq(manifest)
      end
    end

    describe "#creator" do
      context "when a creator is set" do
        it "returns the creator" do
          klass = Class.new
          subject.creator klass
          expect(subject.creator).to eq(klass)
        end
      end
    end

    describe "#form_class" do
      it "returns the default form class when not configured" do
        expect(subject.form_class).to be(Decidim::Admin::ImportForm)
      end

      context "when the form class has been defined" do
        it "returns the defined form class" do
          subject.form_class_name = "Class"
          expect(subject.form_class).to be(Class)
        end
      end
    end

    describe "#messages" do
      it "allows defining and fetching the messages" do
        subject.messages do |msg|
          msg.set(:foo) { "Bar" }
          msg.set(:baz) { "Biz" }

          expect(msg.has?(:foo)).to be(true)
          expect(msg.has?(:baz)).to be(true)
          expect(msg.has?(:biz)).to be(false)

          expect(msg.render(:foo)).to eq("Bar")
          expect(msg.render(:baz)).to eq("Biz")
        end

        expect(subject.messages).to be_a(described_class::ImportManifestMessages)
        expect(subject.messages.has?(:foo)).to be(true)
        expect(subject.messages.render(:foo)).to be("Bar")
      end

      context "when trying to set a message without a block" do
        it "raises an ArgumentError" do
          subject.messages do |msg|
            expect { msg.set(:foo) }.to raise_error(ArgumentError)
          end
        end
      end
    end

    describe "#message" do
      context "when given the key only" do
        before do
          subject.messages do |msg|
            msg.set(:foo) { "Bar" }
            msg.set(:baz) { "Biz" }
          end
        end

        it "fetches the message" do
          expect(subject.message(:foo)).to eq("Bar")
          expect(subject.message(:baz)).to eq("Biz")
        end
      end

      context "when given the key and context" do
        let(:context) { double }

        it "gets the correct context" do
          spec = self
          ctx = context

          subject.messages do |msg|
            msg.set(:foo) do
              spec.expect(self).to spec.eq(ctx)
            end
          end

          expect { subject.message(:foo, ctx) }.not_to raise_error
        end
      end

      context "when given the key and extra parameters as second argument" do
        it "passes the arguments to the definition block" do
          expect do |block|
            subject.messages do |msg|
              msg.set(:foo, &block)
            end

            subject.message(:foo, a: "A", b: "B")
          end.to yield_with_args(a: "A", b: "B")
        end
      end

      context "when given a context and extra params" do
        let(:context) { double }

        it "passes the arguments to the definition block" do
          expect do |block|
            subject.messages do |msg|
              msg.set(:foo, &block)
            end

            subject.message(:foo, context, a: "A", b: "B")
          end.to yield_with_args(a: "A", b: "B")
        end

        it "gets the correct context with the arguments" do
          spec = self
          ctx = context

          subject.messages do |msg|
            msg.set(:foo) do |a:, b:|
              spec.expect(self).to spec.eq(ctx)
              spec.expect(a).to spec.eq("A")
              spec.expect(b).to spec.eq("B")
            end
          end

          expect { subject.message(:foo, ctx, a: "A", b: "B") }.not_to raise_error
        end
      end
    end

    describe "#has_message?" do
      before do
        subject.messages do |msg|
          msg.set(:foo) { "Bar" }
          msg.set(:baz) { "Biz" }
        end
      end

      it "reports the correct messages as existing" do
        expect(subject.has_message?(:foo)).to be(true)
        expect(subject.has_message?(:baz)).to be(true)
        expect(subject.has_message?(:biz)).to be(false)
      end
    end

    describe "#example" do
      context "when given the definition block" do
        let(:data) do
          [
            %w(id title detail),
            [1, "foo", "bar"],
            [2, "baz", "biz"]
          ]
        end

        it "defines an example" do
          example_data = data
          subject.example do |_component|
            example_data
          end

          expect(subject.example).to be(data)
        end
      end

      context "when given a context and a component" do
        let(:component) { create(:component) }

        before do
          subject.example do |comp|
            org = comp.organization
            [
              %w(id) + org.available_locales.map { |l| "name/#{l}" },
              [comp.id] + org.available_locales.map { |l| comp.name[l] }
            ]
          end
        end

        it "returns the example data" do
          expect(subject.example(nil, component)).to eq(
            [
              %w(id name/en name/ca name/es),
              [component.id, component.name["en"], component.name["ca"], component.name["es"]]
            ]
          )
        end
      end
    end
  end
end
