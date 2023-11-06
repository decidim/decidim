# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UrlValidator do
    subject { described_class.new(options) }

    let(:record) do
      Class.new(Decidim::Form) do
        include TranslatableAttributes
        mimic :participatory_process
        attribute :url, String
      end.from_params(url:)
    end
    let(:attribute) { :description }
    let(:options) do
      {
        attributes: [attribute]
      }
    end

    context "with invalid input" do
      it "returns false for a poorly formed URL" do
        expect(subject).not_to be_url_valid("something.com")
      end

      it "returns false for garbage input" do
        pi = 3.14159265
        expect(subject).not_to be_url_valid(pi)
      end

      it "returns false for URLs without an HTTP protocol" do
        expect(subject).not_to be_url_valid("ftp://secret-file-stash.net")
      end
    end

    context "with valid input" do
      it "returns true for a correctly formed HTTP URL" do
        expect(subject).to be_url_valid("http://nooooooooooooooo.com")
      end

      it "returns true for a correctly formed HTTPS URL" do
        expect(subject).to be_url_valid("https://google.com")
      end
    end
  end
end
