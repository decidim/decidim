# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe IconRegistry do
    subject { described_class.new }

    let(:icon1) { { "name" => "my Icon", "icon" => "foo-bar", "description" => "some description", "category" => "action", "engine" => :core } }
    let(:icon2) { { "name" => "my Icon 1", "icon" => "foo-bar", "description" => "some description", "category" => "other_category", "engine" => :core } }
    let(:icon3) { { "name" => "my Icon 2", "icon" => "foo-bar", "description" => "some description", "category" => "action", "engine" => :core } }
    let(:other) { { "name" => "other", "icon" => "question-line", "description" => "Other", "category" => "other_category", "engine" => :core } }

    before do
      subject.register(**icon1.symbolize_keys)
      subject.register(**icon2.symbolize_keys)
      subject.register(**icon3.symbolize_keys)
      subject.register(**other.symbolize_keys)
    end

    describe "#register" do
      it "registers multiple icons" do
        expect(subject.all.size).to eq(4)
        expect(subject.find("my Icon")).to eq(icon1)
        expect(subject.find("my Icon 1")).to eq(icon2)
        expect(subject.find("my Icon 2")).to eq(icon3)
      end

      context "when name is the same" do
        let(:icon2) { icon1.merge("name" => "my Icon") }

        it "overrides the icon if it already exists" do
          expect(subject.all.size).to eq(3)
          expect(subject.find("my Icon")).to eq(icon2)
        end
      end
    end

    describe "#find" do
      it "raises error when name is blank" do
        expect(subject.find("")).to eq(other)
      end
    end

    describe "#categories" do
      it "groups icons by category" do
        expect(subject.categories).to eq({ "action" => [icon1, icon3], "other_category" => [icon2, other] })
      end

      it "groups icons by engine" do
        expect(subject.categories(:engine)).to eq({ "core" => [icon1, icon2, icon3, other] })
      end
    end

    describe "#all" do
      it "returns all registered icons" do
        expect(subject.all).to eq({ "my Icon" => icon1, "my Icon 1" => icon2, "my Icon 2" => icon3, "other" => other })
      end
    end
  end
end
