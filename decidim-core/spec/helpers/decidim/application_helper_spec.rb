# frozen_string_literal: true

require "spec_helper"
require_relative "../../../app/helpers/decidim/application_helper"

module Decidim
  describe ApplicationHelper do
    let(:helper) do
      Class.new.tap do |v|
        v.extend(Decidim::ApplicationHelper)
      end
    end

    describe "#html_truncate" do
      subject { helper.html_truncate(text, length: length) }

      describe "truncating HTML text" do
        let(:text) { "<p>Hello, this is dog</p>" }
        let(:length) { 5 }

        it { is_expected.to eq("<p>Hello...</p>") }
      end

      describe "truncating regular text" do
        let(:text) { "Hello, this is dog" }
        let(:length) { 5 }

        it { is_expected.to eq("Hello...") }
      end

      describe "truncating with a custom separator" do
        subject { helper.html_truncate(text, length: length, separator: " ...read more") }

        let(:text) { "Hello, this is dog" }
        let(:length) { 5 }

        it { is_expected.to eq("Hello ...read more") }
      end
    end

    describe "#present" do
      subject { helper.present(presentable).class }

      context "when presentable's presenter follows naming convention" do
        let(:presentable) { create(:user) }

        it { is_expected.to eq(Decidim::UserPresenter) }
      end

      context "when presentable is nil" do
        let(:presentable) { nil }

        it { is_expected.to eq(Decidim::NilPresenter) }
      end
    end
  end
end
