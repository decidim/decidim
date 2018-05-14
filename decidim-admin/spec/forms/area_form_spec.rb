# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe AreaForm do
      subject { described_class.from_params(attributes).with_context(context) }

      let(:organization) { create :organization }
      let(:name) { Decidim::Faker::Localized.word }
      let(:area_type) { create :area_type }
      let(:attributes) do
        {
          "area" => {
            "name" => name,
            "area_type" => area_type
          }
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
        let(:name) { {} }

        it { is_expected.to be_invalid }
      end

      context "when name is not unique" do
        before do
          create(:area, organization: organization, name: name)
        end

        it "is not valid" do
          expect(subject).not_to be_valid
          expect(subject.errors[:name]).not_to be_empty
        end
      end

      context "when the name exists in another organization" do
        before do
          create(:area, name: name)
        end

        it { is_expected.to be_valid }
      end
    end
  end
end
