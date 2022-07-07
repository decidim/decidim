# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe CommonPasswords do
    subject do
      Class.new(described_class) do
        def self.common_passwords_path
          Rails.root.join("tmp/common-passwords.txt")
        end
      end
    end

    let(:organization) { create(:organization) }
    let(:example_passwords) { %w(VJHT29061987 1234567890 q1w2e3r4t5 tooshort 0000000000) }
    let(:urls) { Decidim::CommonPasswords::URLS }

    context "when file exists and request returns body" do
      before do
        urls.each do |request_url|
          stub_request(:get, request_url)
            .with(
              headers: { "Accept" => "*/*", "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3", "User-Agent" => "Ruby" }
            ).to_return(status: 200, body: example_passwords.join("\n"), headers: {})
        end
      end

      context "when passwords are updated" do
        before { subject.update_passwords! }

        describe "#passwords" do
          it "contains common passwords which are at least 10 characters long" do
            expect(subject.instance.passwords).to eq(example_passwords.reject { |item| item.length < 10 })
          end
        end
      end
    end
  end
end
