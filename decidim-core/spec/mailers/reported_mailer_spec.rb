# -*- coding: utf-8 -*-
require "spec_helper"

module Decidim
  describe ReportedMailer, type: :mailer do
    let(:organization) { create(:organization) }
    let(:user) { create(:user, :admin, organization: organization) }
    let(:feature) { create(:feature, organization: organization) }
    let(:reportable) { create(:dummy_resource, feature: feature) }
    let(:moderation) { create(:moderation, reportable: reportable, participatory_process: feature.participatory_process, report_count: 1) }
    let!(:report) { create(:report, moderation: moderation) }

    describe "#report" do
      let(:mail) { described_class.report(user, report) }

      let(:subject) { "Un contingut ha estat denunciat" }
      let(:default_subject) { "A resource has been reported" }

      let(:body) { "ha estat denunciat" }
      let(:default_body) { "has been reported" }

      include_examples "localised email"
    end

    describe "#hide" do
      let(:mail) { described_class.hide(user, report) }

      let(:subject) { "Un contingut ha estat amagat automàticament" }
      let(:default_subject) { "A resource has been hidden automatically" }

      let(:body) { "ha estat amagat" }
      let(:default_body) { "has been hidden" }

      include_examples "localised email"
    end
  end
end
