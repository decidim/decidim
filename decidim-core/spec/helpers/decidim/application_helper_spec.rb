# frozen_string_literal: true

require "spec_helper"
require_relative "../../../app/helpers/decidim/application_helper"

module Decidim
  describe ApplicationHelper do
    describe "#html_truncate" do
      let(:helper) do
        Class.new.tap do |v|
          v.extend(Decidim::ApplicationHelper)
        end
      end

      subject { helper.html_truncate(text, length: length) }

      context "truncating HTML text" do
        let(:text) { "<p>Hello, this is dog</p>" }
        let(:length) { 5 }

        it { is_expected.to eq("<p>Hello...</p>") }
      end

      context "truncating regular text" do
        let(:text) { "Hello, this is dog" }
        let(:length) { 5 }

        it { is_expected.to eq("Hello...") }
      end

      context "with a custom separator" do
        subject { helper.html_truncate(text, length: length, separator: " ...read more") }
        let(:text) { "Hello, this is dog" }
        let(:length) { 5 }

        it { is_expected.to eq("Hello ...read more") }
      end
    end
  end
end
