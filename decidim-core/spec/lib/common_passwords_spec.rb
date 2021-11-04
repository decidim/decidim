# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe CommonPasswords do
    let(:subject) do
      Class.new(described_class) do
        def password_list_path
          Rails.root.join("tmp/common-passwords.txt")
        end
      end.instance
    end
    let(:organization) { create(:organization) }
    let(:dummy_data) do
      double(
        read: example_passwords
      )
    end
    let(:example_passwords) { "VJHT29061987 1234567890 q1w2e3r4t5 tooshort" }
    let(:urls) { Decidim::CommonPasswords::URLS }

    before do
      urls.each do |request_url|
        stub_request(:get, request_url)
          .with(
            headers: { "Accept" => "*/*", "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3", "User-Agent" => "Ruby" }
          ).to_return(status: 200, body: example_passwords, headers: {})
      end
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
