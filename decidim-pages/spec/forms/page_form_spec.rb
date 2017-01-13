# coding: utf-8
# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Pages
    module Admin
      describe PageForm do
        let(:current_organization) { create(:organization) }

        let(:title) do
          {
            "en" => "Hello world",
            "ca" => "Hola món",
            "es" => "Hola mundo"
          }
        end

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
              "title" => title,
              "body" => body,
              "commentable" => commentable
            }
          }
        end

        subject do
          described_class.from_params(attributes).with_context(
            current_organization: current_organization
          )
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when any title translation is blank" do
          let(:title) do
            {
              "en" => "Hello world",
              "ca" => "Hola món",
              "es" => ""
            }
          end

          it { is_expected.not_to be_valid }
        end
      end
    end
  end
end
