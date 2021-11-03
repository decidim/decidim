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
      before do
        allow(subject).to receive(:common_password_list).and_return(%w(qwertyuiop 1234567890 q1w2e3r4t5))
      end

      it "opens file for writing" do
        Decidim::CommonPasswords::URLS.each do |url|
          allow(URI).to receive(:open).with(url).and_return([::Faker::Lorem.word]).once
        end
        expect(File).to receive(:open).with(password_list_path, "w").once

        subject.update_passwords!
      end
    end

    private

    def password_list_path
      directory = __dir__.sub("/spec/lib", "/lib/decidim")
      File.join(directory, "db", "password-list.txt")
    end
  end
end
