# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe CommonPasswords do
    let(:subject) { described_class.instance }
    let(:dummy_data) do
      double(
        read: example_passwords
      )
    end
    let(:example_url) { "www.example.org/passwords.txt" }
    let(:example_passwords) { "qwertyuiop 1234567890 q1w2e3r4t5 tooshort" }
    let(:test_password_list_path) { Rails.root.join("tmp/common-passwords.txt") }

    before do
      stub_const "Decidim::CommonPasswords::URLS", [example_url]
      allow(URI).to receive(:open).and_yield(dummy_data)
    end

    describe "#passwords" do
      it "returns passwords" do
        expect(subject.passwords).to be_kind_of(Array)
      end
    end

    describe "#update_passwords!" do
      it "opens file for writing" do
        subject.update_passwords!

        expect(subject.passwords).to eq(example_passwords.split.slice(0..-2))
      end
    end
  end
end

module Decidim
  class CommonPasswords
    private

    def password_list_path
      Rails.root.join("tmp/common-passwords.txt")
    end
  end
end
