# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Component do
    subject { component }

    let!(:organization) { create(:organization) }
    let!(:participatory_space) { create(:conference, organization:) }
    let(:component) { build(:component, manifest_name: "dummy", participatory_space:) }

    describe ".private_non_transparent_space?" do
      # since the conferences do not respond to private_space? we are testing and make sure it does not fail
      it { expect(subject).not_to be_private_non_transparent_space }
    end
  end
end
