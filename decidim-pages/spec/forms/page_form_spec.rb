# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Pages
    module Admin
      describe PageForm do
        subject do
          described_class.from_params(attributes).with_context(
            current_organization:
          )
        end

        let(:current_organization) { create(:organization) }

        let(:body) do
          {
            "en" => "<p>Content</p>",
            "ca" => "<p>Contingut</p>",
            "es" => "<p>Contenido</p>"
          }
        end

        let(:commentable) { true }

        let(:attributes) do
          {
            "page" => {
              "body" => body,
              "commentable" => commentable
            }
          }
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end
      end
    end
  end
end
