# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    module Admin
      describe UpdateInitiativesSettings do
        subject { described_class.new(initiatives_settings, form) }

        let(:organization) { create :organization }
        let(:user) { create :user, :admin, :confirmed, organization: organization }
        let(:initiatives_settings) { create :initiatives_settings, organization: organization }
        let(:initiatives_order) { "date" }
        let(:form) do
          double(
            invalid?: invalid,
            current_user: user,
            initiatives_order: initiatives_order
          )
        end
        let(:invalid) { false }

        context "when the form is not valid" do
          let(:invalid) { true }

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when the form is valid" do
          it "broadcasts ok" do
            expect { subject.call }.to broadcast(:ok)
          end

          it "updates the initiatives settings" do
            subject.call
            expect(initiatives_settings.initiatives_order).to eq(initiatives_order)
          end
        end
      end
    end
  end
end
