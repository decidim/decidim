# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe Admin::CreatePartner do
    subject { described_class.new(form, current_user, conference) }

    let(:conference) { create(:conference) }
    let(:user) { nil }
    let!(:current_user) { create :user, :confirmed, organization: conference.organization }
    let(:form) do
      double(
        Admin::PartnerForm,
        invalid?: invalid,
        current_user: current_user,
        name: "Name",
        attributes: {
          name: "name",
          weight: 1,
          partner_type: "main_promotor",
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
      let(:partner) { Decidim::Conferences::Partner.last }

      it "creates a partner" do
        expect { subject.call }.to change { Decidim::Conferences::Partner.count }.by(1)
      end

      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "sets the partner" do
        subject.call
        expect(partner.conference).to eq conference
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with(:create, Decidim::Conferences::Partner, current_user, participatory_space: { title: conference.title }, resource: { title: form.name })
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
      end
    end
  end
end
