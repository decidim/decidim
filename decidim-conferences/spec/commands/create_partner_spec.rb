# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe Admin::CreatePartner do
    subject { described_class.new(form, current_user, conference) }

    let(:conference) { create(:conference) }
    let(:user) { nil }
    let!(:current_user) { create :user, :confirmed, organization: conference.organization }
    let(:logo) do
      ActiveStorage::Blob.create_and_upload!(
        io: File.open(Decidim::Dev.asset("avatar.jpg")),
        filename: "avatar.jpeg",
        content_type: "image/jpeg"
      )
    end

    let(:name) { "Name" }
    let(:partner_type) { "main_promotor" }
    let(:form_klass) { Admin::PartnerForm }
    let(:form_params) do
      {
        conference_partner: {
          name: name,
          weight: 1,
          partner_type: partner_type,
          link: Faker::Internet.url,
          logo: logo
        }
      }
    end
    let(:form) do
      form_klass.from_params(
        form_params
      ).with_context(
        current_user: current_user,
        current_organization: conference.organization
      )
    end

    context "when the form is not valid" do
      let(:name) { nil }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end

      context "when image is invalid" do
        let(:logo) do
          ActiveStorage::Blob.create_and_upload!(
            io: File.open(Decidim::Dev.asset("invalid.jpeg")),
            filename: "avatar.jpeg",
            content_type: "image/jpeg"
          )
        end

        it "prevents uploading" do
          expect { subject.call }.not_to raise_error
          expect { subject.call }.to broadcast(:invalid)
        end
      end
    end

    context "when everything is ok" do
      let(:partner) { Decidim::Conferences::Partner.last }

      it "creates a partner" do
        expect { subject.call }.to change(Decidim::Conferences::Partner, :count).by(1)
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
          .with(:create, Decidim::Conferences::Partner, current_user, { participatory_space: { title: conference.title }, resource: { title: form.name } })
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
      end
    end
  end
end
