# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ParticipatorySpace do
    subject { participatory_space }

    let(:participatory_space) { build(:participatory_space, manifest_name: "dummy") }

    it { is_expected.to be_valid }

    include_examples "activable"
    include_examples "publicable" do
      let(:published) do
        create(:participatory_space, :published)
      end
    end

    describe "validations" do
      it "can't be published if it's not active" do
        expect { subject.publish! }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Published at must be blank")
      end
    end
  end
end
