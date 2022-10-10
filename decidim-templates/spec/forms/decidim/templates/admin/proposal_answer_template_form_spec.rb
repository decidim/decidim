# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Templates
    module Admin
      describe ProposalAnswerTemplateForm do
        subject do
          described_class.from_params(attributes).with_context(
            current_organization: current_organization
          )
        end

        let(:current_organization) { create(:organization) }

        let(:name) do
          {
            "en" => name_english,
            "ca" => "Nom",
            "es" => "Nombre"
          }
        end

        let(:description) do
          {
            "en" => "<p>Content</p>",
            "ca" => "<p>Contingut</p>",
            "es" => "<p>Contenido</p>"
          }
        end

        let(:internal_state) { :accepted }

        let(:name_english) { "Name" }

        let(:attributes) do
          {
            "name" => name,
            "description" => description,
            "internal_state" => internal_state
          }
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when name is not valid" do
          let(:name_english) { "" }

          it { is_expected.not_to be_valid }
        end

        context "when internal_state is not valid" do
          let(:internal_state) { "" }

          it { is_expected.not_to be_valid }
        end
      end
    end
  end
end
