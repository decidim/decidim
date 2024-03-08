# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Templates
    module Admin
      describe ProposalAnswerTemplateForm do
        subject do
          described_class.from_params(attributes).with_context(
            current_organization:
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

        let(:proposal_state_id) { rand(5) }

        let(:name_english) { "Name" }

        let(:attributes) do
          {
            "name" => name,
            "description" => description,
            "proposal_state_id" => proposal_state_id
          }
        end

        context "when everything is OK" do
          it do
            allow(subject).to receive(:proposal_state_id_is_valid).and_return(nil)
            expect(subject).to be_valid
          end
        end

        context "when proposal_state_id is not valid" do
          it { is_expected.not_to be_valid }
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
