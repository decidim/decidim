# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Amendable
    describe CreateForm do
      subject { form }

      let(:amendable) { create(:proposal) }
      let(:amender) { create :user, :confirmed, organization: amendable.organization }

      let(:form) do
        described_class.from_params(form_params).with_context(form_context)
      end

      let(:form_params) do
        {
          amendable_gid: amendable.to_sgid.to_s,
          emendation_fields: emendation_fields
        }
      end

      let(:form_context) do
        {
          current_user: amender,
          current_organization: amendable.organization,
          current_participatory_space: amendable.participatory_space,
          current_component: amendable.component
        }
      end

      it_behaves_like "an amendment form"
    end
  end
end
