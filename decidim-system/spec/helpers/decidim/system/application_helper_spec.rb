# frozen_string_literal: true

require "spec_helper"

module Decidim
  module System
    describe ApplicationHelper do
      let(:admin) { create(:admin) }
      let(:other_admin) do
        create(
          :admin,
          email: "otheradmin@example.org",
          password: "decidim123123123",
          password_confirmation: "decidim123123123"
        )
      end
      let(:helper) do
        Class.new(ActionView::Base) do
          include ApplicationHelper
        end.new(ActionView::LookupContext.new(ActionController::Base.view_paths), {}, [])
      end

      describe "#current_admin?" do
        before do
          allow(helper).to receive(:current_admin).and_return(admin)
        end

        context "when currently signed in admin user is different from the targeted admin user" do
          subject { helper.current_admin?(other_admin) }
          it "returns false" do
            expect(subject).to be(false)
          end
        end

        context "when currently signed in admin user is the target" do
          subject { helper.current_admin?(admin) }
          it "returns true" do
            expect(subject).to be(true)
          end
        end
      end
    end
  end
end
