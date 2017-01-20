# -*- coding: utf-8 -*-
# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Admin
    describe OrganizationForm do
      let(:name) { "My super organization" }
      let(:twitter_handler) { "My awesome handler" }
      let(:welcome_text) do
        {
          en: "Welcome",
          es: "Hola",
          ca: "Hola"
        }
      end
      let(:description) do
        {
          en: "Description, awesome description",
          es: "Descripción",
          ca: "Descripció"
        }
      end
      let(:organization) { create(:organization) }
      let(:attributes) do
        {
          "organization" => {
            "name" => name,
            "default_locale" => :en,
            "available_locales" => %w{en ca es},
            "welcome_text_en" => welcome_text[:en],
            "welcome_text_es" => welcome_text[:es],
            "welcome_text_ca" => welcome_text[:ca],
            "description_en" => description[:en],
            "description_es" => description[:es],
            "description_ca" => description[:ca],
            "homepage_image" => Rack::Test::UploadedFile.new(File.join(File.dirname(__FILE__), "..", "..", "..", "decidim-dev", "spec", "support", "city.jpeg"), "image/jpeg"),
            "show_statics" => false
          }
        }
      end
      let(:context) do
        {
          current_organization: organization,
          current_user: instance_double(Decidim::User).as_null_object
        }
      end

      subject do
        described_class.from_params(attributes).with_context(
          context
        )
      end

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      context "when name is missing" do
        let(:name) { nil }

        it { is_expected.to be_invalid }
      end
    end
  end
end
