# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe StatsRegistry do
    subject { described_class.new }

    let(:result) { 10 }
    let(:resolver) { proc { result } }

    describe "register" do
      it "registers a stat by its name and default options" do
        subject.register :foo, &resolver
        last_stat = subject.stats.last
        expect(last_stat[:primary]).to be_falsy
        expect(last_stat[:priority]).to eq(StatsRegistry::LOW_PRIORITY)
      end

      it "registers a stat by its name and custom options" do
        subject.register :foo, { primary: true, priority: StatsRegistry::HIGH_PRIORITY }, &resolver
        last_stat = subject.stats.last
        expect(last_stat[:primary]).to be_truthy
        expect(last_stat[:priority]).to eq(StatsRegistry::HIGH_PRIORITY)
      end

      it "raises an error if the stat already exists" do
        subject.register :foo, &resolver

        expect { subject.register :foo, &resolver }.to raise_error StandardError
      end
    end

    describe "resolve" do
      before do
        subject.register :foo, &resolver
      end

      it "resolves a stat block given a context" do
        context = { bar: "bar" }
        expect(resolver).to receive(:call).with(context, nil, nil).and_call_original
        expect(subject.resolve(:foo, context)).to eq(result)
      end

      it "resolves a stat block given a context and optional start and end dates" do
        context = { bar: "bar" }
        start_at = 1.week.ago
        end_at = Time.current
        expect(resolver).to receive(:call).with(context, start_at, end_at).and_call_original
        expect(subject.resolve(:foo, context, start_at, end_at)).to eq(result)
      end

      it "raises an error if the stat is not available" do
        expect { subject.resolve :bar, [] }.to raise_error StandardError
      end
    end

    describe "with_context" do
      let(:values) { { foo: 10, bar: 20 } }
      let(:foo_resolver) { proc { |ctx| values[ctx[:foo]] } }
      let(:bar_resolver) { proc { |ctx| values[ctx[:bar]] } }

      before do
        subject.register :foo, &foo_resolver
        subject.register :bar, &bar_resolver
      end

      it "resolves every state registered with the same context" do
        context = { foo: :foo, bar: :bar }
        subject.with_context(context).each do |name, value|
          expect(value).to eq(values[name])
        end
      end
    end

    describe "filter" do
      before do
        subject.register :foo, primary: true, &resolver
        subject.register :bar, primary: false, &resolver
        subject.register :baz, primary: false, priority: StatsRegistry::MEDIUM_PRIORITY, &resolver
      end

      it "returns a new stats registry instance with filtered stats" do
        expect(subject.filter(primary: true).stats.length).to eq(1)
        expect(subject.filter(primary: false).stats.length).to eq(2)
      end
    end

    describe "except" do
      before do
        subject.register :foo, &resolver
        subject.register :bar, &resolver
      end

      it "returns a new stats registry instance with filtered stats" do
        expect(subject.except([:foo]).stats.length).to eq(1)
      end
    end

    describe "only" do
      before do
        subject.register :foo, &resolver
        subject.register :bar, &resolver
        subject.register :baz, &resolver
      end

      it "returns a new stats registry instance with filtered stats" do
        expect(subject.only([:foo]).stats.length).to eq(1)
      end
    end
  end
end
