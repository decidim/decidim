# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Gamification
    describe BadgeRegistry do
      subject { BadgeRegistry.new }

      context "without any registered badges" do
        describe "#all" do
          it "returns an empty array" do
            expect(subject.all).to eq([])
          end
        end
      end

      context "with registered badges" do
        before do
          subject.register(:foo) { |badge| badge.levels = [1, 2, 3] }
          subject.register(:bar) { |badge| badge.levels = [10, 20, 30] }
        end

        describe "#all" do
          it "returns the registered badges" do
            expect(subject.all.map(&:name)).to include("foo", "bar")
          end
        end

        describe "#find" do
          it "returns a badges if found" do
            badge = subject.find(:foo)
            expect(badge.name).to eq("foo")
          end

          it "returns nil if not found" do
            expect(subject.find(:baz)).to be_nil
          end
        end
      end
    end
  end
end
