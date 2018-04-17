# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Consultations
    module Admin
      describe UnpublishConsultation do
        subject { described_class.new(consultation) }

        let(:consultation) { create :consultation, :published }

        context "when the consultation is nil" do
          let(:consultation) { nil }

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when the consultation is not published" do
          let(:consultation) { create :consultation, :unpublished }

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when the consultation is published" do
          it "is valid" do
            expect { subject.call }.to broadcast(:ok)
          end

          it "unpublishes it" do
            subject.call
            consultation.reload
            expect(consultation).not_to be_published
          end
        end
      end
    end
  end
end
