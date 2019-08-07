# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ParticipatorySpaceContextManifest do
    subject { described_class.new }

    describe "#engine" do
      it "can be assigned an engine" do
        klass = Class.new
        subject.engine = klass
        expect(subject.engine).to eq(klass)
      end
    end

    describe "#helper" do
      it "can be assigned a helper" do
        subject.helper = "Decidim::ArbitraryHelper"
        expect(subject.helper).to eq("Decidim::ArbitraryHelper")
      end
    end

    describe "#layout" do
      it "can be assigned a helper" do
        subject.helper = "layouts/decidim/arbitrary_layout"
        expect(subject.helper).to eq("layouts/decidim/arbitrary_layout")
      end
    end
  end
end
