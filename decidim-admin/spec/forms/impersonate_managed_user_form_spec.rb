# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe ImpersonateManagedUserForm do
      let(:organization) { create :organization }
      let(:authorization) do
        {
          handler_name: "decidim/dummy_authorization_handler",
          document_number: "12345678X"
        }
      end
      let(:attributes) do
        {
          authorization: authorization
        }
      end
      subject do
        described_class.from_params(
          attributes
        ).with_context(
          current_organization: organization
        )
      end

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end
    end
  end
end
