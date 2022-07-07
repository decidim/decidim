# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe AttributeObject::Model do
    subject { model.new(attributes) }

    let(:model) do
      c = Class.new do
        include Decidim::AttributeObject::Model

        attribute :any
        attribute :str, String
        attribute :int, Integer
        attribute :flt, Float
        attribute :eng, Rails::Engine, **{}
        attribute :arr, Array[OpenStruct]
        attribute(:hsh, { String => OpenStruct })
      end

      c.attribute :sub, submodel
      c.attribute :sar, Array[submodel]
      c.attribute(:shs, { String => submodel })

      c
    end
    let(:submodel) do
      Class.new do
        include Decidim::AttributeObject::Model

        attribute :name, String
        attribute :role, String
      end
    end
    let(:attributes) do
      {
        any: double,
        str: "string",
        int: 1,
        flt: 1.1,
        eng: Decidim::Core::Engine.instance,
        arr: [OpenStruct.new(foo: "bar"), OpenStruct.new(foo: "baz")],
        hsh: { foo: OpenStruct.new(foo: "bar"), bar: OpenStruct.new(foo: "baz") },
        sub: { id: 1, name: "John", role: "Dough" },
        sar: [{ id: 1, name: "John", role: "Dough" }, { id: 2, name: "Joanna", role: "Donut" }],
        shs: { foo: { id: 1, name: "John", role: "Dough" }, bar: { id: 2, name: "Joanna", role: "Donut" } }
      }
    end

    it "defines all attribute methods and casts their values correctly" do
      expect(subject.any).to eq(attributes[:any])
      expect(subject.str).to eq("string")
      expect(subject.int).to eq(1)
      expect(subject.flt).to eq(1.1)
      expect(subject.eng).to be(Decidim::Core::Engine.instance)
      expect(subject.arr.all? { |i| i.is_a?(OpenStruct) }).to be(true)
      expect(subject.arr[0].foo).to eq("bar")
      expect(subject.arr[1].foo).to eq("baz")

      expect(subject.sub).to be_a(submodel)
      expect(subject.sub.id).to eq(1)
      expect(subject.sub.name).to eq("John")
      expect(subject.sub.role).to eq("Dough")

      expect(subject.sar).to be_a(Array)
      expect(subject.sar.all? { |i| i.is_a?(submodel) }).to be(true)
      expect(subject.sar[0].id).to eq(1)
      expect(subject.sar[0].name).to eq("John")
      expect(subject.sar[0].role).to eq("Dough")
      expect(subject.sar[1].id).to eq(2)
      expect(subject.sar[1].name).to eq("Joanna")
      expect(subject.sar[1].role).to eq("Donut")

      expect(subject.shs).to be_a(Hash)
      expect(subject.shs.all? { |k, i| k.is_a?(String) && i.is_a?(submodel) }).to be(true)
      expect(subject.shs["foo"].id).to eq(1)
      expect(subject.shs["foo"].name).to eq("John")
      expect(subject.shs["foo"].role).to eq("Dough")
      expect(subject.shs["bar"].id).to eq(2)
      expect(subject.shs["bar"].name).to eq("Joanna")
      expect(subject.shs["bar"].role).to eq("Donut")
    end

    context "with multi-dimension form attributes" do
      let(:model) do
        Class.new do
          include Decidim::AttributeObject::Model

          attribute(:date, { Integer => String })
        end
      end
      let(:attributes) do
        {
          "date(1i)" => "2022",
          "date(2i)" => "01",
          "date(3i)" => "02"
        }
      end

      it "converts the provided multi-attributes correctly to hashes" do
        expect(subject.date).to eq(1 => "2022", 2 => "01", 3 => "02")
      end
    end

    describe "#attributes" do
      it "responds to string keys" do
        expect(subject.attributes["any"]).to eq(attributes[:any])
        expect(subject.attributes["str"]).to eq("string")
        expect(subject.attributes["int"]).to eq(1)
        expect(subject.attributes["flt"]).to eq(1.1)
      end

      it "allows slicing the attributes with string keys" do
        expect(subject.attributes.slice("any", "str", "int", "flt")).to eq(
          "any" => attributes[:any],
          "str" => "string",
          "int" => 1,
          "flt" => 1.1
        )
      end

      context "with deprecated keys access" do
        it "responds to symbol keys" do
          expect(subject.attributes[:any]).to eq(attributes[:any])
          expect(subject.attributes[:str]).to eq("string")
          expect(subject.attributes[:int]).to eq(1)
          expect(subject.attributes[:flt]).to eq(1.1)
        end

        it "allows slicing the attributes with symbol keys" do
          expect(subject.attributes.slice(:any, :str, :int, :flt)).to eq(
            "any" => attributes[:any],
            "str" => "string",
            "int" => 1,
            "flt" => 1.1
          )
        end
      end
    end

    describe "#[]" do
      it "returns the attribute value for existing attributes when accessing through #[]" do
        expect(subject[:str]).to eq("string")
      end

      it "returns nil when the provided attribute does not exist" do
        expect(subject[:unexisting]).to be_nil
      end
    end

    describe "#[]=" do
      it "assigns attribute value for existing attributes when assigning through #[]=" do
        subject[:str] = "foo"
        expect(subject.str).to eq("foo")
      end

      it "does nothing when trying to assign an unexisting attribute through #[]=" do
        subject[:unexisting] = "foo"
        expect(subject[:unexisting]).to be_nil
      end
    end

    describe "#attributes_with_values" do
      let(:attributes) do
        {
          str: "string",
          int: 1
        }
      end

      it "returns only the defined attributes and attributes with defaults" do
        expect(subject.attributes_with_values).to eq(
          str: "string",
          int: 1,
          arr: [],
          hsh: {},
          sar: [],
          shs: {}
        )
      end
    end

    describe "#to_h" do
      let(:attributes) do
        {
          str: "string",
          int: 1
        }
      end

      it "returns all attributes excluding :id in a hash with symbol keys" do
        expect(subject.to_h).to eq(
          any: nil,
          str: "string",
          int: 1,
          flt: nil,
          eng: nil,
          arr: [],
          hsh: {},
          sub: nil,
          sar: [],
          shs: {}
        )
      end

      context "with the :id attribute defined" do
        let(:attributes) do
          {
            id: 123,
            str: "string",
            int: 1
          }
        end

        it "returns all attributes in a hash with symbol keys" do
          expect(subject.to_h).to eq(
            id: 123,
            any: nil,
            str: "string",
            int: 1,
            flt: nil,
            eng: nil,
            arr: [],
            hsh: {},
            sub: nil,
            sar: [],
            shs: {}
          )
        end
      end
    end
  end
end
