# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Blogs
    module Admin
      describe PostForm do
        subject do
          described_class.from_params(attributes).with_context(
            current_organization: current_organization
          )
        end

        let(:current_organization) { create(:organization) }

        let(:title) do
          {
            "en" => "Title",
            "ca" => "Títol",
            "es" => "Título"
          }
        end

        let(:body) do
          {
            "en" => "<p>Content</p>",
            "ca" => "<p>Contingut</p>",
            "es" => "<p>Contenido</p>"
          }
        end

        let(:attributes) do
          {
            "post" => {
              "title" => title,
              "body" => body
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
