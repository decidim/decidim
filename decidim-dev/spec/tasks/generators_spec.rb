# frozen_string_literal: true

require "spec_helper"

describe "Executing Decidim Generators tasks" do
  describe "rake decidim:generate", type: :task do
    context "when executing task" do
      it "shows the VAPID public and private keys" do
        Rake::Task[:"decidim:generate"].invoke
        expect($stdout.string).to include("VAPID keys correctly generated.")
        expect($stdout.string).to include("VAPID public key is")
        expect($stdout.string).to include("VAPID private key is")
      end
    end
  end
end
