# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Core
    describe BlobType, type: :graphql do
      include_context "with a graphql class type"

      let(:current_user) { create(:user, :confirmed, :admin, organization: current_organization) }
      let(:model) { attachment.reload.file_blob }

      describe "src" do
        let(:query) { "{ src }" }

        context "when the blob is attached to an attachment in an open space" do
          let(:attachment) do
            create(:attachment, :with_pdf, attached_to: create(:participatory_process, organization: current_organization))
          end

          it "returns the Active Storage url" do
            expect(response["src"]).to include("/rails/active_storage/")
          end
        end

        context "when the blob is attached to an attachment in a restricted space" do
          let(:attachment) do
            create(:attachment, :with_pdf, attached_to: create(:participatory_process, :restricted, :published, organization: current_organization))
          end

          it "does not return the direct Active Storage url" do
            expect(response["src"]).not_to include("/rails/active_storage/")
          end

          it "returns the private download url, which authorizes every request" do
            expect(response["src"]).to include("/private_downloads/")
          end
        end
      end

      describe "authorization" do
        let(:query) { "{ src }" }
        let(:attachment) do
          create(:attachment, :with_pdf, attached_to: create(:participatory_process, organization: current_organization))
        end

        context "with an anonymous user" do
          let(:current_user) { nil }

          it "raises an UnauthorizedObjectError" do
            expect { response }.to raise_error(Decidim::Api::Errors::UnauthorizedObjectError, /you do not have permissions/)
          end
        end

        context "with a regular user" do
          let(:current_user) { create(:user, :confirmed, organization: current_organization) }

          it "raises an UnauthorizedObjectError" do
            expect { response }.to raise_error(Decidim::Api::Errors::UnauthorizedObjectError, /you do not have permissions/)
          end
        end
      end
    end
  end
end
