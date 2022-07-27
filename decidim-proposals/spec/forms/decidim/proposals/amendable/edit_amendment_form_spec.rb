# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Amendable
    describe EditForm do
      subject { form }

      let!(:component) { create(:proposal_component) }
      let!(:amendable) { create(:proposal, component:) }
      let!(:emendation) { create(:proposal, component:) }
      let!(:amendment) { create(:amendment, :draft, amendable:, emendation:) }

      let(:params) do
        {
          id: amendment.id,
          emendation_params:
        }
      end

      let(:context) do
        {
          current_user: amendment.amender,
          current_organization: component.organization
        }
      end

      let(:form) { described_class.from_params(params).with_context(context) }

      it_behaves_like "an amendment form"

      context "when the emendation doesn't change the amendable" do
        let(:emendation_params) { { title: translated(amendable.title), body: amendable.body } }

        it { is_expected.to be_invalid }
      end
    end
  end
end
