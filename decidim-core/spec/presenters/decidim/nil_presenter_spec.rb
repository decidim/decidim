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
        expect(subject).to eq("//localhost:#{Capybara.server_port}#{::Shakapacker.instance.manifest.lookup("media/images/default-avatar.svg")}")
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
  end
end
