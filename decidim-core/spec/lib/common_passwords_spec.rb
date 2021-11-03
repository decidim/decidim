# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe CommonPasswords do
    let(:subject) { described_class.instance }
    let(:data) do
      double(
        read: "qwertyuiop 1234567890 q1w2e3r4t5"
      )
    end

    describe "#passwords" do
      it "returns passwords" do
        expect(subject.passwords).to be_kind_of(Array)
      end
    end

    describe "#update_passwords!" do
      let(:example_url) { "www.example.org/passwords.txt" }
      let(:example_passwords) { "qwertyuiop 1234567890 q1w2e3r4t5 tooshort" }

      before do
        allow(subject).to receive(:password_list_path).and_return(test_password_list_path)
        stub_const "Decidim::CommonPasswords::URLS", [example_url]
        allow(URI).to receive(:open).with(example_url).and_return(example_passwords)
      end

      it "opens file for writing" do
        expect(File).to receive(:open).with(test_password_list_path, "w")

        subject.update_passwords!

        expect(subject.passwords).to eq(example_passwords.split.slice(0..-2))
      end
    end

    private

    def test_password_list_path
      Rails.root.join("tmp/common-passwords.txt")
    end
  end
end
