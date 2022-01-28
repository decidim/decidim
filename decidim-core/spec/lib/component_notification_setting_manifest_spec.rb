# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ComponentNotificationSettingManifest do
    subject { described_class.new }

    let(:default_value) { "1" }
    let(:attributes) do
      {
        default_value: "1"
      }
    end

    context "when all the values are correct" do
      before do
        subject.name = "component_notif_manifest"
        subject.area = "administrators"
      end

      it { is_expected.to be_valid }
    end

    context "without a name" do
      before do
        subject.name = nil
        subject.area = "administrators"
      end

      it { is_expected.to be_valid }
    end

    context "without an area" do
      before do
        subject.area = nil
      end

      it { is_expected.to be_invalid }
    end

    context "with an invalid area" do
      before do
        subject.area = "admin"
      end

      it { is_expected.to be_invalid }
    end

    context "with an invalid default value" do
      before do
        subject.area = "administrators"
        subject.default_value = "true"
      end

      it { is_expected.to be_invalid }
    end
  end
end
