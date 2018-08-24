# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Amendable
    describe CreateForm do
      subject { form }

      let(:resource) { create(:dummy_resource) }
      let(:amender) { create :user, :confirmed, organization: resource.organization }

      let(:form) do
        described_class.from_params(form_params).with_context(form_context)
      end

      let(:emendation_fields) do
        {
          title: "Loura Hansen II 1"
        }
      end

      let(:form_params) do
        {
          amendable_gid: resource.to_sgid.to_s,
          emendation_fields: emendation_fields,
          amender: amender,
          component: resource.component
        }
      end

      let(:form_context) do
        {
          current_user: amender,
          current_organization: resource.organization,
          current_participatory_space: resource.participatory_space,
          current_component: resource.component
        }
      end

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      context "when the amendable_gid is not present" do
        let(:form_params) do
          {
            amendable_gid: nil,
            emendation_fields: emendation_fields,
            amender: amender,
            component: resource.component
          }
        end

        it { is_expected.to be_invalid }
      end
    end
  end
end
