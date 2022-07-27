# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Admin::ActionForm do
  subject(:form) { described_class.from_params(attributes).with_context(context) }

  let(:attributes) { {} }
  let(:context) do
    {
      current_organization: component.organization,
      current_component: component,
      election:
    }
  end
  let(:election) { create :election, :created }
  let(:component) { election.component }

  it { is_expected.to be_valid }

  describe "#pending_action" do
    subject { form.pending_action }

    it { is_expected.to be_nil }

    context "when there is a pending action" do
      let!(:pending_action) { create(:action, election:) }

      it { is_expected.to eq(pending_action) }
    end
  end

  describe "#main_button?" do
    subject { form.main_button? }

    it { is_expected.to be_truthy }
  end
end
