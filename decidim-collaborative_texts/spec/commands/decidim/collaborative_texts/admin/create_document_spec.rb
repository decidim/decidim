# frozen_string_literal: true

require "spec_helper"

module Decidim
  module CollaborativeTexts
    module Admin
      describe CreateDocument do
        subject { described_class.new(form) }

        let(:organization) { create(:organization, available_locales: [:en, :ca, :es], default_locale: :en) }
        let(:participatory_process) { create(:participatory_process, organization:) }
        let(:component) { create(:component, participatory_space: participatory_process, manifest_name: "collaborative_texts") }
        let(:user) { create(:user, :admin, :confirmed, organization:) }
        let(:coauthorship) { build(:coauthorship, coauthorable: nil, organization:) }
        let!(:title) { "This is my document new title" }
        let(:body) { "This is my document body" }
        let(:form) do
          double(
            invalid?: invalid,
            current_user: user,
            title:,
            body:,
            component:,
            current_component: component,
            current_organization: organization,
            coauthorships: [coauthorship]
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

          it "sets the body & title" do
            subject.call
            expect(document.title).to eq title
            expect(document.body).to eq body
          end

          it "sets the component" do
            subject.call
            expect(document.component).to eq component
          end

          it "sets the author" do
            subject.call
            expect(document.creator.author).to eq coauthorship.author
          end

          it "traces the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:create!)
              .with(Decidim::CollaborativeTexts::Document, user, { title:, body:, coauthorships: [coauthorship], component: }, { extra: { body: } })
              .and_call_original

            expect { subject.call }.to change(Decidim::ActionLog, :count)
            action_log = Decidim::ActionLog.last
            expect(action_log.version).to be_present
            expect(action_log.extra["extra"]).to eq({ "body" => body })
          end
        end
      end
    end
  end
end
