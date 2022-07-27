# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe AttributeObject::TypeResolver do
    let(:resolver) { described_class.new }

    describe "#resolve" do
      subject { resolver.resolve(type, **options) }

      let(:type) { double }
      let(:options) { { foo: "bar" } }

      context "with a Symbol type" do
        let(:type) { :foo }

        it "returns the same exact type with the provided options" do
          expect(subject).to eq(type:, options:)
        end
      end

      context "with an ActiveModel::Type::Value type" do
        let(:type) { ActiveModel::Type::Value.new }

        it "returns the same exact type with the provided options" do
          expect(subject).to eq(type:, options:)
        end
      end

      context "with a Class type" do
        context "when implementing Decidim::AttributeObject::Model" do
          let(:type) do
            Class.new do
              include Decidim::AttributeObject::Model
            end
          end

          it "returns a :model type with the correct primitive option" do
            expect(subject).to eq(type: :model, options: { primitive: type, foo: "bar" })
          end
        end

        context "when ActiveRecord::Base" do
          let(:type) { ActiveRecord::Base }

          it "returns a :model type with the correct primitive option" do
            expect(subject).to eq(type: :model, options: { primitive: type, foo: "bar" })
          end
        end

        context "when subclass of ActiveRecord::Base" do
          let(:type) { Decidim::User }

          it "returns a :model type with the correct primitive option" do
            expect(subject).to eq(type: :model, options: { primitive: type, foo: "bar" })
          end
        end

        context "when Hash" do
          let(:type) { Hash }

          it "returns a :hash type with correct default key_type and value_type options" do
            expect(subject).to eq(type: :hash, options: { key_type: Symbol, value_type: Object, default: {}, foo: "bar" })
          end
        end

        context "when Array" do
          let(:type) { Array }

          it "returns an :array type with correct value_type option" do
            expect(subject).to eq(type: :array, options: { value_type: Object, default: [], foo: "bar" })
          end
        end

        context "when existing default type" do
          let(:type) { Integer }

          it "returns an :integer type with correct options" do
            expect(subject).to eq(type: :integer, options: { foo: "bar" })
          end
        end

        context "with a custom class without defined ActiveModel::Type" do
          let(:type) { OpenStruct }

          it "returns an :object type with the correct primitive option" do
            expect(subject).to eq(type: :object, options: { primitive: type, foo: "bar" })
          end
        end
      end

      context "with a Hash type" do
        let(:type) { { String => OpenStruct } }

        it "returns a :hash type with correct key_type and value_type options" do
          expect(subject).to eq(type: :hash, options: { key_type: String, value_type: OpenStruct, default: {}, foo: "bar" })
        end

        context "with custom default option" do
          let(:options) { { default: { "a" => OpenStruct.new } } }

          it "returns a :hash type with correct value_type and defautl options" do
            expect(subject).to eq(type: :hash, options: { key_type: String, value_type: OpenStruct, default: options[:default] })
          end
        end
      end

      context "with an Array type" do
        let(:type) { Array[OpenStruct] }

        it "returns a :hash type with correct value_type option" do
          expect(subject).to eq(type: :array, options: { value_type: OpenStruct, default: [], foo: "bar" })
        end

        context "with custom default option" do
          let(:options) { { default: [OpenStruct.new] } }

          it "returns a :hash type with correct value_type and defautl options" do
            expect(subject).to eq(type: :array, options: { value_type: OpenStruct, default: options[:default] })
          end
        end
      end

      # Test the default resolver
      context "with a String type" do
        let(:type) { "Integer" }

        context "when existing default type" do
          let(:type) { "Integer" }

          it "returns an :integer type with correct options" do
            expect(subject).to eq(type: :integer, options: { foo: "bar" })
          end
        end

        context "with a custom class" do
          let(:type) { "OpenStruct" }

          it "returns an :object type with the correct primitive option" do
            expect(subject).to eq(type: :object, options: { primitive: type, foo: "bar" })
          end
        end
      end
    end
  end
end
