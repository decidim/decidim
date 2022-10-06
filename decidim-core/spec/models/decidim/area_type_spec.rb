# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe AreaType do
    subject(:area_type) { build(:area_type) }

    it { is_expected.to be_valid }

    describe "has an association for areas" do
      subject(:area_type_areas) { area_type.areas }

      let(:areas) { create_list(:area, 2, area_type:) }

      it { is_expected.to contain_exactly(*areas) }
    end

    context "without name" do
      subject(:area_type) { build(:area_type, name: { en: "Name" }) }

      before do
        area_type.name = {}
      end

      it { is_expected.to be_invalid }
    end

    context "without organization" do
      before do
        area_type.organization = nil
      end

      it { is_expected.to be_invalid }
    end
  end
end
