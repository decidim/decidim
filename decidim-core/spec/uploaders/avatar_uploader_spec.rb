# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe AvatarUploader do
    subject { uploader }

    let(:uploader) { described_class.new(model, :avatar) }
    let(:model) { create(:user) }

    describe "#default_url" do
      subject { uploader.default_url }

      let(:asset) { "media/images/default-avatar.svg" }
      let(:correct_asset_path) { ActionController::Base.helpers.asset_pack_path(asset) }

      it { is_expected.to eq("//#{model.organization.host}:#{Capybara.server_port}#{correct_asset_path}") }
    end

    describe "#default_multiuser_url" do
      subject { uploader.default_multiuser_url }

      let(:asset) { "media/images/avatar-multiuser.png" }
      let(:correct_asset_path) { ActionController::Base.helpers.asset_pack_path(asset) }

      it { is_expected.to eq("//#{model.organization.host}:#{Capybara.server_port}#{correct_asset_path}") }
    end
  end
end
