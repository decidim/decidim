# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe Admin::UpdatePartner do
    subject { described_class.new(form, partner) }

    let!(:conference) { create(:conference) }
    let(:partner) { create :partner, :main_promotor, conference: conference }
    let!(:current_user) { create :user, :confirmed, organization: conference.organization }
    let(:form) do
      double(
        Admin::PartnerForm,
        invalid?: invalid,
        current_user: current_user,
        full_name: "New name",
        attributes: {
          name: "New name",
          weight: 2,
          partner_type: "collaborator",
          logo: Decidim::Dev.test_file("avatar.jpg", "image/jpeg"),
          link: Faker::Internet.url,
          remove_logo: false
        }
      )
    end
    let(:invalid) { false }

    context "when the form is not valid" do
      let(:invalid) { true }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when everything is ok" do
      it "updates the partner name" do
        expect do
          subject.call
        end.to change { partner.reload && partner.name }.from(partner.name).to("New name")
      end

      it "updates the partner type" do
        expect do
          subject.call
        end.to change { partner.reload && partner.partner_type }.from(partner.partner_type).to("collaborator")
      end

      it "broadcasts  ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:update!)
          .with(partner, current_user, kind_of(Hash), hash_including(resource: hash_including(:title)))
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
      end
    end
  end
end
