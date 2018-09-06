# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe NavbarLinkForm do
      subject { described_class.from_params(attributes).with_context(context) }

      let(:title) do
        {
          en: "title",
          es: "title",
          ca: "title"
        }
      end
      let(:link) { "https://decidim.org/" }
      let(:weight) { (1..5).to_a.sample }
      let(:organization) { create(:organization) }
      let(:organization_id) { organization.id }
      let(:target) { ["blank", ""].sample }

      let(:attributes) do
        {
          "title" => title,
          "link" => link,
          "target" => target,
          "weight" => weight,
          "organization_id" => organization_id

        }
      end
      let(:context) do
        {
          "current_organization" => organization
        }
      end

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      context "when name is missing" do
        let(:title) { nil }

        it { is_expected.to be_invalid }
      end

      context "when link is missing" do
        let(:link) { nil }

        it { is_expected.to be_invalid }
      end

      context "when weight is missing" do
        let(:weight) { nil }

        it { is_expected.to be_invalid }
      end

      context "when organization id is missing" do
        let(:organization_id) { nil }

        it { is_expected.to be_invalid }
      end

      context "when link doesn't start with http" do
        let(:link) { "foo" }

        it { is_expected.to be_invalid }
      end
    end
  end
end
