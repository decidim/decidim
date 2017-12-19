# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe OfficializationForm do
      subject do
        described_class
          .new(officialized_as: officialized_as, user_id: user_id)
          .with_context(current_organization: organization)
      end

      let(:organization) { create(:organization) }

      let(:officialized_as) do
        { "en" => "Major of Girona" }
      end

      let(:user_id) { create(:user, organization: organization).id }

      it { is_expected.to be_valid }

      context "when the user does not exist" do
        let(:user_id) { 37 }

        it { is_expected.not_to be_valid }
      end

      context "when officialization badge is empty" do
        let(:officialized_as) { {} }

        it { is_expected.to be_valid }
      end
    end
  end
end
