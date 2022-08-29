# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Blogs
    describe PostsController, type: :controller do
      routes { Decidim::Blogs::Engine.routes }
      describe "show" do
        context "when the post has not published yet" do
          let(:organization) { create :organization }
          let(:participatory_process) { create :participatory_process, organization: }
          let!(:post_component) { create(:post_component, participatory_space: participatory_process) }
          let!(:unpublished) { create(:post, component: post_component, created_at: 2.days.ago, published_at: 2.days.from_now) }
          let!(:published) { create(:post, component: post_component, created_at: 2.days.ago, published_at: 2.days.ago) }

          before do
            request.env["decidim.current_organization"] = organization
            request.env["decidim.current_component"] = post_component
            request.env["decidim.current_participatory_space"] = participatory_process
          end

          it "throws exception on non published page" do
            expect { get :show, params: { id: unpublished.id } }
              .to raise_error(ActiveRecord::RecordNotFound)
          end

          it "does notthrow exception on published page" do
            get :show, params: { id: published.id }
            expect(response).to have_http_status(:ok)
          end
        end
      end
    end
  end
end
