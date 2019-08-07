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
          emendation_params: emendation_params
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

      context "when the emendation doesn't change the amendable" do
        let(:emendation_params) { { title: amendable.title, body: amendable.body } }

        it { is_expected.to be_invalid }
      end
    end
  end
end
