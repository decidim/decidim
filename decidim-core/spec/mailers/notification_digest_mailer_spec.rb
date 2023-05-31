# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe NotificationsDigestMailer, type: :mailer do
    let(:organization) { create(:organization, name: "O'Connor") }
    let(:user) { create(:user, name: "Sarah Connor", organization:) }
    let(:notification_ids) { [notification.id] }
    let(:notification) { create(:notification, user:, resource:) }
    let(:component) { create(:component, manifest_name: "dummy", organization:) }
    let(:resource) { create(:dummy_resource, title: { en: %(Testing <a href="/resource">resource</a>) }, component:) }

    describe "digest_mail" do
      subject { described_class.digest_mail(user, notification_ids) }

      it "includes the link to the resource" do
        expect(subject.body).to include(
          %(<a href="#{::Decidim::ResourceLocatorPresenter.new(resource).url}">Testing resource</a>)
        )
      end
    end
  end
end
