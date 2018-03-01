# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe UpdateArea do
    subject { described_class.new(area, form) }

    let(:organization) { create :organization }
    let(:area) { create :area, organization: organization }
    let(:name) { Decidim::Faker::Localized.literal("New name") }
    let(:area_type) { create :area_type, organization: organization }

    let(:form) do
      double(
        invalid?: invalid,
        name: name,
        area_type: area_type
      )
    end
    let(:invalid) { false }

    context "when the form is not valid" do
      let(:invalid) { true }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the form is valid" do
      before do
        subject.call
        area.reload
      end

      it "updates the name of the area" do
        expect(translated(area.name)).to eq("New name")
      end

      it "updates the area type" do
        expect(area.area_type).to eq(area_type)
      end
    end
  end
end
