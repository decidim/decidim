# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Amendable
    describe ReviewForm do
      subject { form }

      let(:component) { create(:proposal_component) }
      let(:amendable) { create(:proposal, component:) }
      let(:emendation) { create(:proposal, component:) }
      let(:amendment) { create(:amendment, amendable:, emendation:) }

      let(:form) do
        described_class.from_params(form_params).with_context(form_context)
      end

      let(:form_params) do
        {
          id: amendment.id,
          emendation_params:
        }
      end

      let(:form_context) do
        {
          current_user: amendable.creator_author,
          current_organization: amendable.organization,
          current_participatory_space: amendable.participatory_space,
          current_component: amendable.component
        }
      end

      it_behaves_like "an amendment form"
    end
  end
end
