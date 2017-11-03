# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ViewHooks do
    subject { described_class.new }

    describe "register" do
      it "saves the hooks in priority order" do
        subject.register(:test_hook, priority: 3) { "Lower priority" }
        subject.register(:test_hook, priority: 1) { "Higher priority" }

        priorities = subject.send(:hooks)[:test_hook].map(&:priority)
        expect(priorities).to eq [1, 3]

        subject.register(:test_hook, priority: 2) do
          "Medium priority"
        end

        priorities = subject.send(:hooks)[:test_hook].map(&:priority)
        expect(priorities).to eq [1, 2, 3]
      end

      it "defaults priority to 3" do
        subject.register(:test_hook) do
          "Medium priority"
        end

        priorities = subject.send(:hooks)[:test_hook].map(&:priority)
        expect(priorities).to eq [3]
      end
    end

    describe "render" do
      it "joins the result of the blocks in an HTML string" do
        subject.register(:test_hook, priority: 3) { "b" }
        subject.register(:test_hook, priority: 1) { "a" }

        result = subject.render(:test_hook, nil)
        expect(result).to eq "ab"
        expect(result).to be_html_safe
      end
    end
  end
end
