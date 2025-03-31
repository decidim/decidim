# frozen_string_literal: true

require "spec_helper"

describe "rake decidim:verifications:revoke:sms", type: :task do
  context "when executing task" do
    it "does not throw exceptions" do
      expect do
        Rake::Task[:"decidim:verifications:revoke:sms"].invoke
      end.not_to raise_exception
    end
  end

  context "when there are no sms authorizations" do
    let!(:other_authorizations) { create_list(:authorization, 8, name: "other_authorization") }

    it "it does not remove the authorizations" do
      expect { task.execute }.not_to change(Decidim::Authorization, :count)
    end
  end

  context "when there are authorizations" do
    let!(:sms_authorizations) { create_list(:authorization, 8, name: "sms") }
    let!(:other_authorizations) { create_list(:authorization, 3, name: "other_authorization") }

    it "it removes the authorization" do
      expect { task.execute }.to change(Decidim::Authorization, :count).by(-8)
    end
  end
end
