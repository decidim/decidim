# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe DataPortabilityFileReader do
    subject { DataPortabilityFileReader.new(user, token) }

    let(:user) { create :user }
    let(:token) { SecureRandom.base58(10) }

    describe "#file_name" do
      it "expects the filename" do
        "#{user.nickname}-#{user.organization.name.parameterize}-#{token}.zip"
      end
    end

    describe "#file_path" do
      it "expects the full path of file" do
        Decidim::DataPortabilityUploader.new.store_dir + "#{user.nickname}-#{user.organization.name.parameterize}-#{token}.zip"
      end
    end

    describe "#valid_token?" do
      it "expects present token and length equal 10" do
        expect(token).not_to be_empty
        expect(token.length).to eq(10)
      end
    end
  end
end
