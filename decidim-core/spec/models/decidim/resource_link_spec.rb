# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ResourceLink do
    subject { link }

    let(:link) { build(:resource_link) }

    it { is_expected.to be_valid }

    describe "validations" do
      context "without from" do
        before do
          link.from = nil
        end

        it { is_expected.to be_invalid }
      end

      context "without to" do
        before do
          link.to = nil
        end

        it { is_expected.to be_invalid }
      end

      context "without name" do
        before do
          link.name = nil
        end

        it { is_expected.to be_invalid }
      end

      context "when an exact link already exists" do
        let(:link) { build(:resource_link, name: "test-link") }

        before do
          create(:resource_link, name: "test-link", to: link.to, from: link.from)
        end

        it { is_expected.to be_invalid }
      end

      context "when from & to are from different organizations" do
        before do
          link.to = create(:dummy_resource)
          link.from = create(:dummy_resource)
        end

        it { is_expected.to be_invalid }
      end
    end
  end
end
