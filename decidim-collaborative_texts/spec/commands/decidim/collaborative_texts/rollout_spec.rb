# frozen_string_literal: true

require "spec_helper"

module Decidim
  module CollaborativeTexts
    describe Rollout do
      subject { described_class.new(form) }

      let!(:document) { create(:collaborative_text_document, :with_body) }
      let(:organization) { document.component.organization }
      let(:user) { create(:user, :confirmed, organization:) }
      let(:form) do
        double(
          invalid?: invalid,
          body:,
          document:,
          draft:,
          current_user: user,
          current_organization: organization
        )
      end
      let(:draft) { false }
      let(:body) { ::Faker::HTML.paragraph }
      let(:invalid) { false }

      context "when the form is not valid" do
        let(:invalid) { true }

        it "is not valid" do
          expect { subject.call }.to broadcast(:invalid)
        end
      end

      context "when everything is ok" do
        # todo
      end
    end
  end
end
