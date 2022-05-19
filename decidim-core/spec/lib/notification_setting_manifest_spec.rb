# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe NotificationSettingManifest do
    subject { described_class.new }

    context "when all the values are correct" do
      before do
        subject.name = "component_notif_manifest"
        subject.settings_area = "administrators"
      end

      it { is_expected.to be_valid }
    end

    context "without a name" do
      before do
        subject.name = nil
        subject.settings_area = "administrators"
      end

      it { is_expected.to be_valid }
    end

    context "without an area" do
      before do
        subject.settings_area = nil
      end

      it { is_expected.to be_invalid }
    end

    context "with an invalid area" do
      before do
        subject.settings_area = "admin"
      end

      it { is_expected.to be_invalid }
    end

    context "with an invalid default value" do
      before do
        subject.settings_area = "administrators"
        subject.default_value = nil
      end

      it { is_expected.to be_invalid }
    end
  end
end
