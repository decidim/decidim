# frozen_string_literal: true
require "spec_helper"

describe Decidim do
  before :each do
    Decidim.instance_variable_set(:@stats, {})
  end

  describe "register_stat" do
    it "registers a stat by its name and sets primary to false by default" do
      Decidim.register_stat :foo, Proc.new { 10 }
      expect(Decidim.stats[:foo][:primary]).to be_falsy
    end

    it "registers a primary stat if the primary option is enabled" do
      Decidim.register_stat :bar, { primary: true }, Proc.new { 10 }
      expect(Decidim.stats[:bar][:primary]).to be_truthy
    end
  end

  describe "stats_for" do
    before do
      Decidim.register_stat :foo, Proc.new { 10 }
    end

    it "returns the value registered" do
      expect(Decidim.stats_for :foo, []).to eq(10)
    end

    it "passes arguments to the block executed" do
      block = Proc.new { 10 }
      features = [:foo, :bar]
      start_at = Time.current
      end_at = Time.current + 1.day
      expect(block).to receive(:call).with(features, start_at, end_at)
      Decidim.register_stat :bar, block
      Decidim.stats_for :bar, features, start_at, end_at
    end

    it "raises an error if the stat is not registered" do
      expect {
        Decidim.stats_for :bar, []
      }.to raise_error StandardError
    end
  end
end
