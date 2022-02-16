# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe AttributeObject::TypeMap do
    subject do
      c = Class.new
      c.include(described_class)

      c
    end

    describe "Boolean" do
      it "returns the :boolean type" do
        expect(subject.const_get(:Boolean)).to be(:boolean)
      end
    end

    describe "Decimal" do
      it "returns the :decimal type" do
        expect(subject.const_get(:Decimal)).to be(:decimal)
      end
    end
  end
end
