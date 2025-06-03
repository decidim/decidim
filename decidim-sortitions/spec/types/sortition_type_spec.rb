# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Sortitions
    describe SortitionType, type: :graphql do
      include_context "with a graphql class type"

      let(:model) { create(:sortition) }
      let(:organization) { model.organization }

      include_examples "taxonomizable interface"
      describe "id" do
        let(:query) { "{ id }" }

        it "returns all the required fields" do
          expect(response).to include("id" => model.id.to_s)
        end
      end

      describe "dice" do
        let(:query) { "{ dice }" }

        it "returns the dice field" do
          expect(response["dice"]).to eq(model.dice)
        end
      end

      describe "targetItems" do
        let(:query) { "{ targetItems }" }

        it "returns the targetItems field" do
          expect(response["targetItems"]).to eq(model.target_items)
        end
      end

      describe "requestTimestamp" do
        let(:query) { "{ requestTimestamp }" }

        it "returns when the sortition was created" do
          expect(response["requestTimestamp"]).to eq(model.request_timestamp.to_time.iso8601)
        end
      end

      describe "selectedProposals" do
        let(:query) { "{ selectedProposals }" }

        it "returns all the required fields" do
          response_ids = response["selectedProposals"].map { |selected_proposal| selected_proposal }
          expect(response_ids).to eq(model.selected_proposals)
        end
      end

      describe "witnesses" do
        let(:query) { '{ witnesses { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["witnesses"]["translation"]).to eq(model.witnesses["en"])
        end
      end

      describe "reference" do
        let(:query) { "{ reference }" }

        it "returns the reference field" do
          expect(response["reference"]).to eq(model.reference)
        end
      end

      describe "additionalInfo" do
        let(:query) { '{ additionalInfo { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["additionalInfo"]["translation"]).to eq(model.additional_info["en"])
        end
      end

      describe "title" do
        let(:query) { '{ title { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["title"]["translation"]).to eq(model.title["en"])
        end
      end

      describe "createdAt" do
        let(:query) { "{ createdAt }" }

        it "returns when the sortition was created" do
          expect(response["createdAt"]).to eq(model.created_at.to_time.iso8601)
        end
      end

      describe "updatedAt" do
        let(:query) { "{ updatedAt }" }

        it "returns when the sortition was updated" do
          expect(response["updatedAt"]).to eq(model.updated_at.to_time.iso8601)
        end
      end

      describe "url" do
        let(:query) { "{ url }" }

        it "returns all the required fields" do
          expect(response["url"]).to eq(Decidim::ResourceLocatorPresenter.new(model).url)
        end
      end

      describe "candidateProposals" do
        let(:query) { "{ candidateProposals }" }

        it "returns the candidateProposals field" do
          expect(response["candidateProposals"]).to eq(model.candidate_proposals)
        end
      end

      context "when the sortition is cancelled" do
        let(:component) { create(:sortition_component) }
        let(:author) { create(:user, :confirmed, :admin, organization: component.organization) }
        let(:model) { create(:sortition, :cancelled, component:, author:, cancelled_by_user: author) }

        describe "cancelReason" do
          let(:query) { '{ cancelReason { translation(locale: "en")}}' }

          it "returns all the required fields" do
            expect(response["cancelReason"]["translation"]).to eq(model.cancel_reason["en"])
          end
        end

        describe "cancelledOn" do
          let(:query) { "{ cancelledOn }" }

          it "returns when the sortition was cancelled" do
            expect(response["cancelledOn"]).to eq(model.cancelled_on.to_date.iso8601)
          end
        end

        describe "cancelledByUser" do
          let(:query) { "{ cancelledByUser { name }}" }

          it "returns the user that cancelled the sortition" do
            expect(response["cancelledByUser"]["name"]).to eq(model.cancelled_by_user.name)
          end
        end

        context "when participatory space is private" do
          let(:participatory_space) { create(:participatory_process, :with_steps, :private, organization: current_organization) }
          let(:current_component) { create(:sortition_component, participatory_space:) }
          let(:model) { create(:sortition, component: current_component) }
          let(:query) { "{ id }" }

          it "returns nothing" do
            expect(response).to be_nil
          end
        end

        context "when participatory space is private but transparent" do
          let(:participatory_space) { create(:assembly, :private, :transparent, organization: current_organization) }
          let(:current_component) { create(:sortition_component, :published, participatory_space:) }
          let(:model) { create(:sortition, component: current_component) }
          let(:query) { "{ id }" }

          it "returns the object" do
            expect(response).to include("id" => model.id.to_s)
          end
        end

        context "when participatory space is not published" do
          let(:participatory_space) { create(:participatory_process, :with_steps, :unpublished, organization: current_organization) }
          let(:current_component) { create(:sortition_component, participatory_space:) }
          let(:model) { create(:sortition, component: current_component) }
          let(:query) { "{ id }" }

          it "returns nothing" do
            expect(response).to be_nil
          end
        end

        context "when component is not published" do
          let(:current_component) { create(:sortition_component, :unpublished, organization: current_organization) }
          let(:model) { create(:sortition, component: current_component) }
          let(:query) { "{ id }" }

          it "returns nothing" do
            expect(response).to be_nil
          end
        end
      end
    end
  end
end
