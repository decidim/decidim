# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe LogsController do
      routes { Decidim::Admin::Engine.routes }

      let(:organization) { create(:organization) }
      let(:current_user) { create(:user, :admin, :confirmed, organization:) }

      before do
        request.env["decidim.current_organization"] = organization
        sign_in current_user, scope: :user
      end

      describe "GET index" do
        it "renders the index template" do
          get :index

          expect(response).to render_template("index")
        end
      end

      describe "skip_bullet" do
        context "when Bullet supports skipping" do
          it "uses Bullet.skip, runs the block and leaves Bullet enabled" do
            expect(Bullet).to receive(:skip).and_call_original

            executed = false
            expect { controller.send(:skip_bullet) { executed = true } }.not_to change(Bullet, :enable?)
            expect(executed).to be(true)
          end
        end

        context "when Bullet does not support skipping" do
          before do
            allow(Bullet).to receive(:respond_to?).and_call_original
            allow(Bullet).to receive(:respond_to?).with(:skip).and_return(false)
          end

          it "disables Bullet while running the block and restores it afterwards" do
            previous_value = Bullet.enable?
            enabled_during_block = nil

            controller.send(:skip_bullet) { enabled_during_block = Bullet.enable? }

            expect(enabled_during_block).to be(false)
            expect(Bullet.enable?).to eq(previous_value)
          end
        end
      end
    end
  end
end
