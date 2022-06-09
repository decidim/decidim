# frozen_string_literal: true

require "spec_helper"

describe "Executing Decidim Generators tasks" do
  describe "rake decidim:generate_vapid_keys", type: :task do
    context "when executing task" do
      it "shows the VAPID public and private keys" do
        Rake::Task[:"decidim:pwa:generate_vapid_keys"].invoke
        expect($stdout.string).to include("VAPID keys correctly generated.")
        expect($stdout.string).to include("VAPID_PUBLIC_KEY")
        expect($stdout.string).to include("VAPID_PRIVATE_KEY")
      end
    end
  end
end
