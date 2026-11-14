# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Conferences
    describe ConferenceRegistration do
      subject { conference_registration }

      let(:conference) { create(:conference) }
      let(:registration_type) { create(:registration_type, conference:) }
      let(:user) { create(:user, organization: conference.organization) }
      let(:conference_registration) { create(:conference_registration, conference:, registration_type:, user:) }

      it { is_expected.to be_valid }

      describe "counter cache" do
        it "increments the registration_type counter when a conference registration is created" do
          other_user = create(:user, organization: conference.organization)

          expect do
            create(:conference_registration, conference:, registration_type:, user: other_user)
          end.to change { registration_type.reload.conference_registrations_count }.by(1)
        end

        it "decrements the registration_type counter when a conference registration is destroyed" do
          conference_registration

          expect do
            conference_registration.destroy!
          end.to change { registration_type.reload.conference_registrations_count }.by(-1)
        end

        it "updates both registration_types counters when a conference registration is reassigned" do
          other_registration_type = create(:registration_type, conference:)
          conference_registration

          conference_registration.update!(registration_type: other_registration_type)

          expect(registration_type.reload.conference_registrations_count).to eq(0)
          expect(other_registration_type.reload.conference_registrations_count).to eq(1)
        end

        context "with concurrent creations" do
          it_behaves_like "a concurrency safe counter cache" do
            let(:counter_parent) { registration_type }
            let(:counter_column) { :conference_registrations_count }
            let(:counter_children) do
              space = conference
              users = create_list(:user, 5, organization: conference.organization)

              users.map do |registrant|
                ->(parent) { create(:conference_registration, conference: space, registration_type: parent, user: registrant) }
              end
            end
          end
        end
      end
    end
  end
end
