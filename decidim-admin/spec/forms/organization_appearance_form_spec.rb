# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe OrganizationAppearanceForm do
      subject do
        described_class.from_params(attributes).with_context(
          context
        )
      end

      let(:header_snippets) { "<my-html />" }
      let(:organization) { create(:organization) }
      let(:empty_translatable) { { en: "", es: "", ca: "" } }
      let(:attributes) do
        {
          "organization" => {
            "show_statics" => false,
            "header_snippets" => header_snippets
          }
        }
      end
      let(:context) do
        {
          current_organization: organization,
          current_user: instance_double(Decidim::User).as_null_object
        }
      end

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end
    end
  end
end
