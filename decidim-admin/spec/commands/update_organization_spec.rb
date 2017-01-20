# -*- coding: utf-8 -*-
# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Admin
    describe UpdateOrganization, :db do
      describe "call" do
        let(:organization) { create(:organization) }
        let(:params) do
          {
            organization: {
              name: "My super organization",
              default_locale: "en",
              welcome_text_en: "Welcome",
              welcome_text_es: "Hola",
              welcome_text_ca: "Hola",
              description_en: "My description",
              description_es: "Mi descripción",
              description_ca: "La meva descripció",
              show_statistics: false
            }
          }
        end
        let(:context) do
          { current_organization: organization }
        end
        let(:form) do
          OrganizationForm.from_params(params).with_context(context)
        end
        let(:command) { described_class.new(organization, form) }

        describe "when the form is not valid" do
          before do
            expect(form).to receive(:invalid?).and_return(true)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't update the organization" do
            command.call
            organization.reload

            expect(organization.name).to_not eq("My super organization")
          end
        end

        describe "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "updates the organization in the organization" do
            expect { command.call }.to broadcast(:ok)
            organization.reload

            expect(organization.name).to eq("My super organization")
          end

          context "when no homepage image is set" do
            it "does not replace the homepage image" do
              command.call
              organization.reload

              expect(organization.homepage_image).to be_present
            end
          end
        end
      end
    end
  end
end
