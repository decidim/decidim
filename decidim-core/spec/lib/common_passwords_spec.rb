# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe CommonPasswords do
    let(:subject) { described_class }

    let(:organization) { create(:organization) }
    let(:example_passwords) { %w(VJHT29061987 1234567890 q1w2e3r4t5 tooshort 0000000000) }
    let(:urls) { Decidim::CommonPasswords::URLS }

    context "when file exists and request returns body" do
      before do
        stub_const "#{subject}::COMMON_PASSWORDS_PATH", Rails.root.join("tmp/common-passwords.txt")
        urls.each do |request_url|
          stub_request(:get, request_url)
            .with(
              headers: { "Accept" => "*/*", "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3", "User-Agent" => "Ruby" }
            ).to_return(status: 200, body: example_passwords.join("\n"), headers: {})
        end
      end

      describe "#passwords" do
        it "returns passwords" do
          expect(subject.instance.passwords).to be_kind_of(Array)
        end
      end

      describe ".update_passwords!" do
        it "updates passwords" do
          subject.update_passwords!

          expect(subject.instance.passwords).to eq(example_passwords.reject { |item| item.length < 10 })
        end
      end
    end
  end
end
