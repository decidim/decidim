# frozen_string_literal: true

require "spec_helper"

describe "Initiative Components" do
  describe "private_non_transparent_space?" do
    subject { component }

    let!(:organization) { create(:organization) }

    let(:participatory_space) { create(:initiative, organization:) }
    let(:component) { create(:component, manifest_name: "another_dummy", participatory_space:) }

    context "when the component belongs to a space that does not respond to private_space?" do
      it "returns false" do
        expect(subject.private_non_transparent_space?).to be false
      end
    end
  end
end
