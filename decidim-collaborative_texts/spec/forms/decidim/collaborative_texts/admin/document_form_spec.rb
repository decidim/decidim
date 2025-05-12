# frozen_string_literal: true

require "spec_helper"

module Decidim
  module CollaborativeTexts
    module Admin
      describe DocumentForm do
        subject(:form) { described_class.from_params(attributes).with_context(context) }

        let(:organization) { create(:organization) }
        let(:context) do
          {
            current_organization: organization,
            current_component:,
            current_participatory_space: participatory_process
          }
        end
        let(:participatory_process) { create(:participatory_process, organization:) }
        let(:current_component) { create(:component, participatory_space: participatory_process) }
        let(:title) { ::Faker::Lorem.sentence(word_count: 3) }
        let(:body) { ::Faker::HTML.paragraph }
        let(:accepting_suggestions) { false }
        let(:announcement) { ::Faker::HTML.paragraph }
        let(:attributes) do
          {
            title:,
            body:,
            accepting_suggestions:,
            announcement:
          }
        end

        it_behaves_like "etiquette validator", fields: [:title]

        it { is_expected.to be_valid }

        describe "when title is missing" do
          let(:title) { nil }

          it { is_expected.to be_valid }
        end

        describe "when title is empty" do
          let(:title) { "" }

          it { is_expected.not_to be_valid }
        end

        describe "when body is missing" do
          let(:body) { nil }

          it { is_expected.to be_valid }
        end

        describe "when body is empty" do
          let(:body) { "" }

          it { is_expected.not_to be_valid }
        end

        describe "when body is short" do
          let(:body) { "a" }

          it { is_expected.to be_valid }
        end
      end
    end
  end
end
