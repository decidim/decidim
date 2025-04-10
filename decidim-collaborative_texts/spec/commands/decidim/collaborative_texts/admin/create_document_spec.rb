# frozen_string_literal: true

require "spec_helper"

module Decidim
  module CollaborativeTexts
    module Admin
      describe CreateDocument do
        subject { described_class.new(form) }

        let(:organization) { create(:organization, available_locales: [:en, :ca, :es], default_locale: :en) }
        let(:participatory_process) { create(:participatory_process, organization:) }
        let(:current_component) { create(:component, participatory_space: participatory_process, manifest_name: "collaborative_texts") }
        let(:user) { create(:user, :admin, :confirmed, organization:) }
        let!(:title) { "This is my document new title" }
        let(:body) { "This is my document body" }
        let(:form) do
          double(
            invalid?: invalid,
            current_user: user,
            title:,
            body:,
            current_component:,
            component: current_component,
            current_organization: organization
          )
        end
        let(:invalid) { false }

        context "when the form is not valid" do
          let(:invalid) { true }

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when everything is ok" do
          let(:document) { Decidim::CollaborativeTexts::Document.last }

          it "creates the document" do
            expect { subject.call }.to change(Decidim::CollaborativeTexts::Document, :count).by(1)
          end

          it "sets the component" do
            subject.call
            expect(document.component).to eq current_component
          end
        end
      end
    end
  end
end
