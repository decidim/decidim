# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe IconRegistry do
    subject { described_class.new }

    let(:hash) { { "name" => "my Icon", "icon" => "foo-bar", "resource" => "core", "description" => "some description", "category" => "action", "engine" => :core } }
    let(:other_hash) { { "name" => "my Icon 1", "icon" => "foo-bar", "resource" => "core", "description" => "some description", "category" => "other_category", "engine" => :core } }
    let(:yet_another_hash) { { "name" => "my Icon 2", "icon" => "foo-bar", "resource" => "core", "description" => "some description", "category" => "action", "engine" => :core } }

    before do
      subject.register(**hash.symbolize_keys)
      subject.register(**other_hash.symbolize_keys)
      subject.register(**yet_another_hash.symbolize_keys)
    end

    describe "#register" do
      it "registers multiple icons" do
        expect(subject.all.size).to eq(3)
        expect(subject.find("my Icon")).to eq(hash)
        expect(subject.find("my Icon 1")).to eq(other_hash)
        expect(subject.find("my Icon 2")).to eq(yet_another_hash)
      end

      context "when name is the same" do
        let(:other_hash) { hash.merge("name" => "my Icon") }

        it "overrides the icon if it already exists" do
          expect(subject.all.size).to eq(2)
          expect(subject.find("my Icon")).to eq(other_hash)
        end
      end
    end

    describe "#find" do
      it "raises error when name is blank" do
        expect { subject.find("") }.to raise_error("Icon name cannot be blank")
      end
    end

    describe "#categories" do
      it "groups icons by category" do
        expect(subject.categories).to eq({ "action" => [hash, yet_another_hash], "other_category" => [other_hash] })
      end

      it "groups icons by engine" do
        expect(subject.categories(:engine)).to eq({ "core" => [hash, other_hash, yet_another_hash] })
      end
    end

    describe "#all" do
      it "returns all registered icons" do
        expect(subject.all).to eq({ "my Icon" => hash, "my Icon 1" => other_hash, "my Icon 2" => yet_another_hash })
      end
    end
  end
end
