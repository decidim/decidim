# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Area do
    subject(:area) { build(:area) }

    it { is_expected.to be_valid }
    it { is_expected.to be_versioned }

    context "with two areas with the same name and organization" do
      let!(:existing_area) { create(:area, name: area.name, organization: area.organization) }

      it { is_expected.to be_invalid }
    end

    context "with two areas with the same name in different organizations" do
      let!(:existing_area) { create(:area, name: area.name) }

      it { is_expected.to be_valid }
    end

    context "without name" do
      before do
        area.name = {}
      end

      it { is_expected.to be_invalid }
    end

    context "without organization" do
      before do
        area.organization = nil
      end

      it { is_expected.to be_invalid }
    end
  end
end
