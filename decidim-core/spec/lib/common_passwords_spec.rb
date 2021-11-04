# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe CommonPasswords do
    let(:organization) { create(:organization) }
    let(:dummy_data) do
      double(
        read: example_passwords
      )
    end
    let(:example_passwords) { "VJHT29061987 1234567890 q1w2e3r4t5 tooshort" }
    let(:test_password_list_path) { Rails.root.join("tmp/common-passwords.txt") }
    let(:urls) { Decidim::CommonPasswords::URLS }

    before do
      urls.each do |request_url|
        stub_request(:get, request_url)
          .with(
            headers: { "Accept" => "*/*", "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3", "User-Agent" => "Ruby" }
          ).to_return(status: 200, body: example_passwords, headers: {})
      end
      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(described_class).to receive(:password_list_path).and_return(test_password_list_path)
      # rubocop:enable RSpec/AnyInstance
    end

    describe "#passwords" do
      it "returns passwords" do
        expect(described_class.instance.passwords).to be_kind_of(Array)
      end
    end

    describe "#update_passwords!" do
      it "opens file for writing" do
        described_class.instance.update_passwords!

        expect(described_class.instance.passwords).to eq(example_passwords.split.slice(0..-2))
      end
    end
  end
end
