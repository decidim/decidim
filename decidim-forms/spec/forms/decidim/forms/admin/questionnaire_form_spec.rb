# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Forms
    module Admin
      describe QuestionnaireForm do
        subject do
          described_class.from_params(attributes).with_context(
            current_organization:
          )
        end

        let(:current_organization) { create(:organization) }

        let(:title) do
          {
            "en" => "Title",
            "ca" => "Title",
            "es" => "Title"
          }
        end

        let(:tos) do
          {
            "en" => tos_english,
            "ca" => "<p>TOS: contingut</p>",
            "es" => "<p>TOS: contenido</p>"
          }
        end

        let(:description) do
          {
            "en" => "<p>Content</p>",
            "ca" => "<p>Contingut</p>",
            "es" => "<p>Contenido</p>"
          }
        end

        let(:tos_english) { "<p>TOS: content</p>" }

        let(:attributes) do
          {
            "questionnaire" => {
              "tos" => tos,
              "title" => title,
              "description" => description
            }
          }
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when tos is not valid" do
          let(:tos_english) { "" }

          it { is_expected.not_to be_valid }
        end
      end
    end
  end
end
