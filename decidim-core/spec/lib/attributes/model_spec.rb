# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Attributes::Model do
    subject { type }

    let(:type) { described_class.new(primitive:) }
    let(:primitive) { ::Object }

    describe "#type" do
      it "returns :model" do
        expect(subject.type).to be(:model)
      end
    end

    describe "#cast" do
      subject { type.cast(value) }

      context "when the value is an instance of the primitive type" do
        let(:value) { Object.new }

        it "returns the value itself" do
          expect(subject).to be(value)
        end
      end

      context "when the value implements Decidim::AttributeObject::Model" do
        let(:value_type) { Class.new { include Decidim::AttributeObject::Model } }
        let(:value) { value_type.new }

        it "returns the value itself" do
          expect(subject).to be(value)
        end
      end

      context "when the value is a hash and the primitive can be initialized with a hash" do
        let(:primitive) do
          Class.new do
            include Decidim::AttributeObject::Model

            attribute :name
          end
        end
        let(:value) { { name: "John Doe" } }

        it "returns a new instance of the primitive with the correct values" do
          expect(subject).to be_a(primitive)
          expect(subject.name).to eq("John Doe")
        end
      end

      context "when the value responds to_h and the primitive can be initialized with a hash" do
        let(:primitive) do
          Class.new do
            include Decidim::AttributeObject::Model

            attribute :name
          end
        end
        let(:value) { double }
        let(:value_hash) { { name: "John Doe" } }

        before do
          allow(value).to receive(:to_h).and_return(value_hash)
        end

        it "returns a new instance of the primitive with the correct values" do
          expect(subject).to be_a(primitive)
          expect(subject.name).to eq("John Doe")
        end
      end

      context "when the value responds attributes and the primitive can be initialized with a hash" do
        let(:primitive) do
          Class.new do
            include Decidim::AttributeObject::Model

            attribute :name
          end
        end
        let(:value) { double }
        let(:attributes) { { name: "John Doe" } }

        before do
          allow(value).to receive(:attributes).and_return(attributes)
        end

        it "returns a new instance of the primitive with the correct values" do
          expect(subject).to be_a(primitive)
          expect(subject.name).to eq("John Doe")
        end
      end

      context "when the value is an Active Record object and the primitive is a form" do
        let(:primitive) do
          Class.new(Decidim::Form) do
            attr_reader :provided_model

            def map_model(model)
              @provided_model = model
            end
          end
        end
        let(:value) { create(:organization) }

        it "calls the map_model method on the created primitive record" do
          expect(subject).to be_a(primitive)
          expect(subject.provided_model).to be(value)
        end
      end

      context "when the value does not match any of the expected value conditions" do
        let(:value) { double }

        it "returns the value itself" do
          expect(subject).to be(value)
        end
      end
    end
  end
end
