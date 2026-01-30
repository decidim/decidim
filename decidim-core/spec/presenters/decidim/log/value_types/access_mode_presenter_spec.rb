# frozen_string_literal: true

require "spec_helper"

describe Decidim::Log::ValueTypes::AccessModePresenter, type: :helper do
  subject { described_class.new(value, helper) }

  describe "#present" do
    context "when value is nil" do
      let(:value) { nil }

      it "returns nil" do
        expect(subject.present).to be_nil
      end
    end

    context "when value is 0 (open)" do
      let(:value) { 0 }

      it "returns the translated 'Open' label" do
        expect(subject.present).to eq "Open"
      end
    end

    context "when value is '0' (open as string)" do
      let(:value) { "0" }

      it "returns the translated 'Open' label" do
        expect(subject.present).to eq "Open"
      end
    end

    context "when value is 1 (transparent)" do
      let(:value) { 1 }

      it "returns the translated 'Transparent' label" do
        expect(subject.present).to eq "Transparent"
      end
    end

    context "when value is '1' (transparent as string)" do
      let(:value) { "1" }

      it "returns the translated 'Transparent' label" do
        expect(subject.present).to eq "Transparent"
      end
    end

    context "when value is 2 (restricted)" do
      let(:value) { 2 }

      it "returns the translated 'Restricted' label" do
        expect(subject.present).to eq "Restricted"
      end
    end

    context "when value is '2' (restricted as string)" do
      let(:value) { "2" }

      it "returns the translated 'Restricted' label" do
        expect(subject.present).to eq "Restricted"
      end
    end

    context "when value is an invalid access mode" do
      let(:value) { 999 }

      it "returns the not found message" do
        expect(subject.present).to eq "Access mode 999 not found"
      end
    end

    context "when value is a negative number" do
      let(:value) { -1 }

      it "returns the not found message" do
        expect(subject.present).to eq "Access mode -1 not found"
      end
    end
  end
end
