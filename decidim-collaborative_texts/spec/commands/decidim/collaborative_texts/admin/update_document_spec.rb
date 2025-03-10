# frozen_string_literal: true

require "spec_helper"

module Decidim
  module CollaborativeTexts
    module Admin
      describe UpdateDocument do
        subject { described_class.new(form, document) }

        let(:document) { create(:collaborative_text_document, :with_body) }
        let(:organization) { document.component.organization }
        let(:user) { create(:user, :admin, :confirmed, organization:) }
        let(:title) { "This is my document new title" }
        let(:body) { ::Faker::HTML.paragraph }
        let(:form) do
          double(
            invalid?: invalid,
            current_user: user,
            title:,
            body:
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
          it "updates the document" do
            subject.call
            expect(document.title).to eq title
            expect(document.body).to eq body
          end
        end

        describe "#update_document" do
          before do
            allow(Decidim.traceability).to receive(:update!)
          end

          context "when the title changes" do
            it "updates the title and calls traceability update" do
              subject.call
              expect(Decidim.traceability).to have_received(:update!).with(
                document,
                user,
                { title: },
                hash_including(:extra)
              )
            end
          end
        end
      end
    end
  end
end
