# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe NilPresenter do
    subject { ::Decidim::NilPresenter.new.send(method) }

    describe "#deleted?" do
      let(:method) { :deleted? }

      it { is_expected.to be true }
    end

    describe "#avatar_url" do
      let(:method) { :avatar_url }

      it "returns the default avatar url" do
        expect(subject.starts_with?("/assets/decidim/default-avatar-")).to be true
        expect(subject.ends_with?(".svg")).to be true
      end
    end

    describe "#render" do
      let(:method) { :render }

      it { is_expected.to eq("") }
    end

    describe "#translated_name" do
      let(:method) { :translated_name }

      it { is_expected.to eq("") }
    end

    describe "#url" do
      let(:method) { :url }

      it { is_expected.to eq("") }
    end

    describe "#path" do
      let(:method) { :path }

      it { is_expected.to eq("") }
    end

    describe "with user related methods" do
      [:nickname, :badge, :profile_path, :display_mention].each do |method|
        let(:method) { method }

        it { is_expected.to eq("") }
      end
    end

    describe "with resource_locator related methods" do
      [:resource, :path, :url, :index, :admin_index, :show, :edit].each do |method|
        subject { ::Decidim::NilPresenter.new.send(method, {}) }

        let(:method) { method }

        it { is_expected.to eq("") }
      end
    end

    describe "with metrics related methods" do
      [:highlighted, :not_highlighted, :highlighted_metrics, :not_highlighted_metrics].each do |method|
        let(:method) { method }

        it { is_expected.to eq("") }
      end
    end

    describe "with metrics related methods" do
      [:highlighted, :not_highlighted, :highlighted_metrics, :not_highlighted_metrics].each do |method|
        let(:method) { method }

        it { is_expected.to eq("") }
      end
    end

    describe "with hashtag related methods" do
      [:name, :hashtag_path, :display_hashtag, :display_hashtag_name].each do |method|
        let(:method) { method }

        it { is_expected.to eq("") }
      end
    end
  end
end
