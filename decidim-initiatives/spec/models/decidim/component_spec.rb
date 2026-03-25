# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Component do
    subject { component }

    let(:component) { build(:component, manifest_name: "dummy", participatory_space:) }
    let!(:participatory_space) { create(:initiative, organization:) }
    let!(:organization) { create(:organization) }

    it { is_expected.to act_as_paranoid }

    describe ".restricted_space?" do
      # since the initiatives do not respond to restricted_space? we are testing and make sure it does not fail
      it { expect(subject).not_to be_restricted_space }
    end
  end
end
