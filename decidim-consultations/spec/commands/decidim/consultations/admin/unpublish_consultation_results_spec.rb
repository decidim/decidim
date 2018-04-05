# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Consultations
    module Admin
      describe UnpublishConsultationResults do
        subject { described_class.new(consultation) }

        let(:consultation) { create :consultation, :published_results }

        context "when the consultation is nil" do
          let(:consultation) { nil }

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when the consultation results are not published" do
          let(:consultation) { create :consultation, :unpublished_results }

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when the consultation results are published" do
          it "is valid" do
            expect { subject.call }.to broadcast(:ok)
          end

          it "unpublishes it" do
            subject.call
            consultation.reload
            expect(consultation).not_to be_results_published
          end
        end
      end
    end
  end
end
