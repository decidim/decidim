# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Admin::ReportMissingTrusteeForm do
  subject(:form) { described_class.from_params(attributes).with_context(context) }

  let(:context) do
    {
      current_organization: component.organization,
      current_component: component,
      election:,
      current_step:
    }
  end
  let(:component) { election.component }
  let(:current_step) { election.bb_status }
  let(:attributes) { { trustee_id: } }
  let(:election) { create :election, :tally_started }
  let(:trustee) { election.trustees.first }
  let(:trustee_id) { trustee.id }

  it { is_expected.to be_valid }

  describe "#main_button?" do
    subject { form.main_button? }

    it { is_expected.to be_falsey }
  end

  describe "#trustee" do
    subject { form.trustee }

    it { is_expected.to eq(trustee) }
  end
end
