# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Component do
    subject { component }

    let!(:organization) { create(:organization) }
    let!(:participatory_space) { create(:initiative, organization:) }
    let(:component) { build(:component, manifest_name: "dummy", participatory_space:) }

    describe ".private_non_transparent_space?" do
      # since the conferences don't respond to private_space? we are testing and mae sure it doesn't fail
      it { expect(subject.private_non_transparent_space?).to be_falsey }
    end
  end
end
