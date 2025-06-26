# frozen_string_literal: true

require "spec_helper"
require "decidim/dev/test/form_to_param_shared_examples"

module Decidim
  module Elections
    module Admin
      describe ResponseOptionForm do
        subject do
          described_class.from_params(
            response_option: attributes
          ).with_context(current_organization: organization)
        end

        let(:organization) { create(:organization) }

        let(:attributes) do
          {
            body_en: "Body en",
            body_ca: "Body ca",
            body_es: "Body es"
          }
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when the main body is not present" do
          before { attributes[:body_en] = "" }

          it { is_expected.not_to be_valid }
        end

        context "when deleted is true" do
          before do
            attributes[:deleted] = true
            attributes[:body_en] = ""
          end

          it { is_expected.to be_valid }
        end

        it_behaves_like "form to param", default_id: "questionnaire-question-response-option-id"
      end
    end
  end
end
