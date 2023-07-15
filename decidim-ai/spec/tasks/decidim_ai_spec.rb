# frozen_string_literal: true

require "spec_helper"

describe "Executing Decidim Ai tasks" do
  describe "rake decidim:ai:create_reporting_user", type: :task do
    context "when executing task" do
      let!(:organization) { create(:organization) }

      it "successfully invokes the user creation" do
        expect { Rake::Task[:"decidim:ai:create_reporting_user"].invoke }.to change(Decidim::User, :count).by(1)
      end
    end
  end
end
