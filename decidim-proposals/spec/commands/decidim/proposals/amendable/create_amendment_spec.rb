# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Amendable
    describe Create do
      let!(:component) do
        create(:proposal_component,
               :with_amendments_enabled)
      end
      let!(:user) { create :user, :confirmed, organization: component.organization }
      let!(:amendable) { create(:proposal, component: component) }
      let(:command) { described_class.new(form) }

      let(:form) do
        Decidim::Amendable::CreateForm.from_params(form_params).with_context(form_context)
      end

      let(:emendation_fields) do
        {
          title: "Emendation title",
          body: "Emendation body"
        }
      end

      let(:form_params) do
        {
          amendable_gid: amendable.to_sgid.to_s,
          emendation_fields: emendation_fields
        }
      end

      let(:form_context) do
        {
          current_user: user,
          current_organization: component.organization,
          current_participatory_space: component.participatory_space,
          current_component: component
        }
      end

      include_examples "create amendment"
    end
  end
end
