# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Proposals
    describe ProposalType, type: :graphql do
      include_context "with a graphql class type"
      let(:component) { create(:proposal_component) }
      let(:model) { create(:proposal, :with_votes, :with_endorsements, :with_amendments, component:) }
      let(:organization) { model.organization }

      include_examples "taxonomizable interface"
      include_examples "attachable interface"
      include_examples "coauthorable interface"
      include_examples "fingerprintable interface"
      include_examples "amendable interface"
      include_examples "amendable proposals interface"
      include_examples "traceable interface"
      include_examples "timestamps interface"
      include_examples "likable interface"

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the proposal's id" do
          expect(response["id"]).to eq(model.id.to_s)
        end
      end

      describe "voteCount" do
        let(:query) { "{ voteCount }" }

        context "when votes are not hidden" do
          it "returns the amount of votes for this proposal" do
            expect(response["voteCount"]).to eq(model.votes.count)
          end
        end

        context "when votes are hidden" do
          let(:component) { create(:proposal_component, :with_votes_hidden) }

          it "returns nil" do
            expect(response["voteCount"]).to be_nil
          end
        end
      end

      describe "title" do
        let(:query) { '{ title { translation(locale: "en")}}' }

        it "returns the proposal's title" do
          expect(response["title"]["translation"]).to eq(model.title["en"])
        end
      end

      describe "body" do
        let(:query) { '{ body { translation(locale: "en")}}' }

        it "returns the proposal's body" do
          expect(response["body"]["translation"]).to eq(model.body["en"])
        end
      end

      describe "state" do
        let(:query) { "{ state }" }

        it "returns the proposal's state" do
          expect(response["state"]).to eq(model.state)
        end
      end

      context "when is answered" do
        before do
          model.answer = { en: "Some answer" }
          model.answered_at = Time.current
          model.save!
        end

        describe "answer" do
          let(:query) { '{ answer { translation(locale:"en") } }' }

          it "returns the proposal's answer" do
            expect(response["answer"]["translation"]).to eq(model.answer["en"])
          end
        end

        describe "answeredAt" do
          let(:query) { "{ answeredAt }" }

          it "returns when was this query answered at" do
            expect(response["answeredAt"]).to eq(model.answered_at.to_time.iso8601)
          end
        end
      end

      describe "publishedAt" do
        let(:query) { "{ publishedAt }" }

        it "returns when was this query published at" do
          expect(response["publishedAt"]).to eq(model.published_at.to_time.iso8601)
        end
      end

      describe "address" do
        let(:query) { "{ address }" }

        it "returns the address of this proposal" do
          expect(response["address"]).to eq(model.address)
        end
      end

      describe "coordinates" do
        let(:query) { "{ coordinates { latitude longitude } }" }

        before do
          model.latitude = 2
          model.longitude = 40
          model.save!
        end

        it "returns the meeting's address" do
          expect(response["coordinates"]).to include(
            "latitude" => model.latitude,
            "longitude" => model.longitude
          )
        end
      end

      describe "participatory_text_level" do
        let(:query) { "{ participatoryTextLevel }" }

        it "returns the participatory_text_level of this proposal" do
          expect(response["participatoryTextLevel"]).to eq(model.participatory_text_level)
        end
      end

      describe "position" do
        let(:query) { "{ position }" }

        it "returns the position of this proposal" do
          expect(response["position"]).to eq(model.position)
        end
      end

      describe "created_in_meeting" do
        let(:query) { "{ createdInMeeting }" }

        it "returns the created_in_meeting of this proposal" do
          expect(response["createdInMeeting"]).to eq(model.created_in_meeting)
        end
      end

      describe "meeting" do
        let(:query) { '{ meeting { title { translation(locale:"en") } } }' }
        let(:model) { create(:proposal, :official_meeting, component:) }

        it "returns the meeting of this proposal" do
          expect(response["meeting"]["title"]["translation"]).to eq(model.authors.first.title["en"])
        end
      end

      context "when participatory space is private" do
        let(:participatory_space) { create(:participatory_process, :with_steps, :private, organization: current_organization) }
        let(:current_component) { create(:proposal_component, participatory_space:) }
        let(:model) { create(:proposal, component: current_component) }
        let(:query) { "{ id }" }

        it "returns nothing" do
          expect(response).to be_nil
        end
      end

      context "when participatory space is private but transparent" do
        let(:participatory_space) { create(:assembly, :private, :transparent, organization: current_organization) }
        let(:current_component) { create(:proposal_component, participatory_space:) }
        let(:model) { create(:proposal, component: current_component) }
        let(:query) { "{ id }" }

        it "returns the model" do
          expect(response).to include("id" => model.id.to_s)
        end
      end

      context "when participatory space is not published" do
        let(:participatory_space) { create(:participatory_process, :with_steps, :unpublished, organization: current_organization) }
        let(:current_component) { create(:proposal_component, participatory_space:) }
        let(:model) { create(:proposal, component: current_component) }
        let(:query) { "{ id }" }

        it "returns nothing" do
          expect(response).to be_nil
        end
      end

      context "when component is not published" do
        let(:current_component) { create(:proposal_component, :unpublished, organization: current_organization) }
        let(:model) { create(:proposal, component: current_component) }
        let(:query) { "{ id }" }

        it "returns nothing" do
          expect(response).to be_nil
        end
      end

      context "when proposal is moderated" do
        let(:model) { create(:proposal, :hidden) }
        let(:query) { "{ id }" }
        let(:root_value) { model.reload }

        it "returns all the required fields" do
          expect(response).to be_nil
        end
      end
    end
  end
end
