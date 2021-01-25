# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Initiatives
    describe InitiativeApiType, type: :graphql do
      include_context "with a graphql class type"

      let(:model) { create(:initiatives_type) }

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the id field" do
          expect(response).to include("id" => model.id.to_s)
        end
      end

      describe "title" do
        let(:query) { '{ title { translation(locale: "en")}}' }

        it "returns the title field" do
          expect(response["title"]["translation"]).to eq(model.title["en"])
        end
      end

      describe "createdAt" do
        let(:query) { "{ createdAt }" }

        it "returns when the initiative type was created" do
          expect(response["createdAt"]).to eq(model.created_at.to_time.iso8601)
        end
      end

      describe "updatedAt" do
        let(:query) { "{ updatedAt }" }

        it "returns when the initiative type was updated" do
          expect(response["updatedAt"]).to eq(model.updated_at.to_time.iso8601)
        end
      end

      describe "description" do
        let(:query) { '{ description { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["description"]["translation"]).to eq(model.description["en"])
        end
      end

      describe "bannerImage" do
        let(:query) { "{ bannerImage }" }

        it "returns the banner image field" do
          expect(response["bannerImage"]).to eq(model.banner_image.to_s)
        end
      end

      describe "collectUserExtraFields" do
        let(:query) { "{ collectUserExtraFields }" }

        it "returns the collect user extra fields field" do
          expect(response["collectUserExtraFields"]).to eq(model.collect_user_extra_fields)
        end
      end

      describe "extraFieldsLegalInformation" do
        let(:query) { "{ extraFieldsLegalInformation }" }

        it "returns the extra fields legal information field" do
          expect(response["extraFieldsLegalInformation"]).to eq(model.extra_fields_legal_information)
        end
      end

      describe "minimumCommitteeMembers" do
        let(:query) { "{ minimumCommitteeMembers }" }

        it "returns the minimum committee members field" do
          expect(response["minimumCommitteeMembers"]).to eq(model.minimum_committee_members)
        end
      end

      describe "validateSmsCodeOnVotes" do
        let(:query) { "{ validateSmsCodeOnVotes }" }

        it "returns the validate sms code on votes field" do
          expect(response["validateSmsCodeOnVotes"]).to eq(model.validate_sms_code_on_votes)
        end
      end

      describe "undoOnlineSignaturesEnabled" do
        let(:query) { "{ undoOnlineSignaturesEnabled }" }

        it "returns the undo online signatures enabled field" do
          expect(response["undoOnlineSignaturesEnabled"]).to eq(model.undo_online_signatures_enabled)
        end
      end

      describe "promotingComitteeEnabled" do
        let(:query) { "{ promotingComitteeEnabled }" }

        it "returns the promoting comittee enabled field" do
          expect(response["promotingComitteeEnabled"]).to eq(model.promoting_committee_enabled)
        end
      end

      describe "signatureType" do
        let(:query) { "{ signatureType }" }

        it "returns the signature type field" do
          expect(response["signatureType"]).to eq(model.signature_type)
        end
      end

      describe "initiatives" do
        let(:query) { "{ initiatives { id } }" }

        context "when there are no initiatives" do
          it "returns the initiatives for this type" do
            expect(response["initiatives"]).to eq(model.initiatives)
          end
        end

        context "when there are initiatives" do
          let(:initiatives) { create_list(:initiative, initiatives_type: model, organization: :current_organization) }

          it "returns the initiatives" do
            ids = response["initiatives"].map { |item| item["id"] }
            expect(ids).to include(*model.initiatives.map(&:id).map(&:to_s))
          end
        end
      end
    end
  end
end
