# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/softdeleteable_components_examples"

module Decidim
  module Conferences
    describe Admin::ConferencesController do
      routes { Decidim::Conferences::AdminEngine.routes }

      let(:organization) { create(:organization) }
      let(:current_user) { create(:user, :confirmed, :admin, organization:) }
      let!(:conference) do
        create(
          :conference,
          :published,
          organization:
        )
      end

      before do
        request.env["decidim.current_organization"] = organization
        request.env["decidim.current_conference"] = conference
        sign_in current_user
      end

      describe "PATCH update" do
        let(:conference_params) do
          {
            title: conference.title,
            slogan: conference.slogan,
            description: conference.description,
            short_description: conference.short_description,
            weight: conference.weight,
            slug: conference.slug,
            start_date: conference.start_date,
            end_date: conference.end_date,
            registrations_enabled: conference.registrations_enabled,
            registration_terms: conference.registration_terms,
            available_slots: conference.available_slots
          }
        end

        it "uses the slug param as conference id" do
          expect(Decidim::Conferences::Admin::ConferenceForm).to receive(:from_params).with(hash_including(id: conference.id.to_s)).and_call_original

          patch :update, params: { slug: conference.id, conference: conference_params }

          expect(response).to redirect_to edit_conference_path(conference)
        end
      end

      it_behaves_like "a soft-deletable space",
                      space_name: :conference,
                      space_path: :conferences_path,
                      trash_path: :manage_trash_conferences_path
    end
  end
end
