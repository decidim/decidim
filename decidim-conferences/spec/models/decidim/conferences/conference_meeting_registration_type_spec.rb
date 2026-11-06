# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Conferences
    describe ConferenceMeetingRegistrationType do
      subject { registration }

      let(:registration_type) { create(:registration_type) }
      let(:registration) { create(:conference_meeting_registration_type, registration_type:) }

      it { is_expected.to be_valid }

      describe "counter cache" do
        it "increments the registration_type counter when a conference meeting registration type is created" do
          expect do
            create(:conference_meeting_registration_type, registration_type:)
          end.to change { registration_type.reload.conference_meeting_registration_types_count }.by(1)
        end

        it "decrements the registration_type counter when a conference meeting registration type is destroyed" do
          registration

          expect do
            registration.destroy!
          end.to change { registration_type.reload.conference_meeting_registration_types_count }.by(-1)
        end

        it "updates both registration_types counters when a conference meeting registration type is reassigned" do
          other_registration_type = create(:registration_type, conference: registration_type.conference)
          registration

          registration.update!(registration_type: other_registration_type)

          expect(registration_type.reload.conference_meeting_registration_types_count).to eq(0)
          expect(other_registration_type.reload.conference_meeting_registration_types_count).to eq(1)
        end

        context "with concurrent creations" do
          it_behaves_like "a concurrency safe counter cache" do
            let(:counter_parent) { registration_type }
            let(:counter_column) { :conference_meeting_registration_types_count }
            let(:counter_children) do
              meetings = create_list(:conference_meeting, 5, conference: registration_type.conference)

              meetings.map do |meeting|
                ->(parent) { create(:conference_meeting_registration_type, registration_type: parent, conference_meeting: meeting) }
              end
            end
          end
        end
      end
    end
  end
end
