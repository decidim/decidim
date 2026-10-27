# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Verifications
    module IdDocuments
      module Admin
        describe ConfigController do
          routes { Decidim::Verifications::IdDocuments::AdminEngine.routes }

          let(:payload) { %(<img src=x onerror="alert(document.domain)">) }
          let(:organization) { create(:organization, available_authorizations: ["id_documents"]) }
          let(:admin) { create(:user, :admin, :confirmed, organization:) }

          before do
            request.env["decidim.current_organization"] = organization
            sign_in admin, scope: :user
          end

          describe "PUT update" do
            # The input path intentionally stores the value as-is; the security
            # boundary is the output sanitization tested in
            # ../authorizations_xss_spec.rb.
            it "stores the raw HTML supplied in a direct request" do
              put :update, params: {
                config: {
                  online: false,
                  offline: true,
                  offline_explanation_en: payload
                }
              }

              expect(organization.reload.id_documents_explanation_text["en"]).to include("onerror")
            end
          end
        end
      end
    end
  end
end
