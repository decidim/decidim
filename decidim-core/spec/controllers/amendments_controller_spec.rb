# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe AmendmentsController, type: :controller do
    routes { Decidim::Core::Engine.routes }

    let!(:participatory_process) { create(:participatory_process, :with_steps) }
    let(:active_step_id) { participatory_process.active_step.id }
    let(:step_settings) { { active_step_id => { amendment_creation_enabled: true } } }
    let(:settings) { { amendments_enabled: true } }
    let!(:component) { create(:component, participatory_space: participatory_process, settings:, step_settings:) }
    let(:other_user) { create(:user, :confirmed, organization: component.organization) }

    let!(:amendable) { create(:dummy_resource, component:) }
    let!(:emendation) { create(:dummy_resource, component:) }
    let!(:amendment) { create(:amendment, amendable:, emendation:, state: amendment_state) }
    let(:amendment_state) { "evaluating" }

    let(:params) { { id: amendment.id } }

    before do
      request.env["decidim.current_organization"] = amendable.organization
      sign_in user
    end

    describe "GET compare_draft" do
      context "when the amendment is a draft" do
        let(:amendment_state) { "draft" }

        context "and the user is NOT the amender" do
          let(:user) { other_user }

          it "redirects to 404" do
            expect do
              get :compare_draft, params:
            end.to raise_error(ActionController::RoutingError)
          end
        end
      end

      context "when the user is the amender" do
        let(:user) { amendment.amender }

        context "and the amendment is NOT a draft" do
          it "redirects to 404" do
            expect do
              get :compare_draft, params:
            end.to raise_error(ActionController::RoutingError)
          end
        end

        context "and the amendment is a draft" do
          let(:amendment_state) { "draft" }

          context "with similar emendations" do
            let!(:similar_emendation) { create(:dummy_resource, :published, title: emendation.title, component:) }
            let!(:similar_amendment) { create(:amendment, amendable:, emendation: similar_emendation) }

            it "renders the view: compare_draft" do
              allow(Decidim::SimilarEmendations).to receive(:for).and_return([similar_emendation])
              get :compare_draft, params: params
              expect(subject).to render_template(:compare_draft)
            end
          end

          context "without similar emendations" do
            it "redirects to edit_draft" do
              get :compare_draft, params: params
              expect(response).to redirect_to edit_draft_amend_path(amendment)
            end
          end
        end
      end
    end

    describe "GET edit_draft" do
      context "when the amendment is a draft" do
        let(:amendment_state) { "draft" }

        context "and the user is NOT the amender" do
          let(:user) { other_user }

          it "redirects to 404" do
            expect do
              get :edit_draft, params:
            end.to raise_error(ActionController::RoutingError)
          end
        end
      end

      context "when the user is the amender" do
        let(:user) { amendment.amender }

        context "and the amendment is NOT a draft" do
          it "redirects to 404" do
            expect do
              get :edit_draft, params:
            end.to raise_error(ActionController::RoutingError)
          end
        end

        context "and the amendment is a draft" do
          let(:amendment_state) { "draft" }

          it "renders the view: edit_draft" do
            get :edit_draft, params: params
            expect(subject).to render_template(:edit_draft)
          end
        end
      end
    end

    describe "PATCH update_draft" do
      let(:emendation_params) do
        {
          title: "Lorem ipsum dolor sit amet.",
          body: "Ut sed dolor vitae purus volutpat venenatis."
        }
      end

      context "when the amendment is a draft" do
        let(:amendment_state) { "draft" }

        context "and the user is NOT the amender" do
          let(:user) { other_user }

          it "redirects to 404" do
            expect do
              post :update_draft, params: params.merge(
                emendation_params:
              )
            end.to raise_error(ActionController::RoutingError)
          end
        end
      end

      context "when the user is the amender" do
        let(:user) { amendment.amender }

        context "and the amendment is NOT a draft" do
          it "redirects to 404" do
            expect do
              post :update_draft, params: params.merge(
                emendation_params:
              )
            end.to raise_error(ActionController::RoutingError)
          end
        end

        context "and the amendment is a draft" do
          let(:amendment_state) { "draft" }

          it "updates the draft" do
            post :update_draft, params: params.merge(
              emendation_params:
            )
            expect(flash[:notice]).to eq("Amendment draft successfully updated.")
          end
        end
      end
    end

    describe "DELETE destroy_draft" do
      context "when the amendment is a draft" do
        let(:amendment_state) { "draft" }

        context "and the user is NOT the amender" do
          let(:user) { other_user }

          it "redirects to 404" do
            expect do
              delete :destroy_draft, params:
            end.to raise_error(ActionController::RoutingError)
          end
        end
      end

      context "when the user is the amender" do
        let(:user) { amendment.amender }

        context "and the amendment is NOT a draft" do
          it "redirects to 404" do
            expect do
              delete :destroy_draft, params:
            end.to raise_error(ActionController::RoutingError)
          end
        end

        context "and the amendment is a draft" do
          let(:amendment_state) { "draft" }

          it "destroys the draft" do
            delete :destroy_draft, params: params
            expect(flash[:notice]).to eq("Amendment draft was successfully deleted.")
          end
        end
      end
    end

    describe "GET preview_draft" do
      context "when the amendment is a draft" do
        let(:amendment_state) { "draft" }

        context "and the user is NOT the amender" do
          let(:user) { other_user }

          it "redirects to 404" do
            expect do
              get :preview_draft, params:
            end.to raise_error(ActionController::RoutingError)
          end
        end
      end

      context "when the user is the amender" do
        let(:user) { amendment.amender }

        context "and the amendment is NOT a draft" do
          it "redirects to 404" do
            expect do
              get :preview_draft, params:
            end.to raise_error(ActionController::RoutingError)
          end
        end

        context "and the amendment is a draft" do
          let(:amendment_state) { "draft" }

          it "renders the view: preview_draft" do
            get :preview_draft, params: params
            expect(subject).to render_template(:preview_draft)
          end
        end
      end
    end

    describe "POST publish_draft" do
      let(:emendation_params) { { title: emendation.title, body: emendation.body } }
      let(:amendable_params) { { title: amendable.title, body: amendable.body } }

      context "when the amendment is a draft" do
        let(:amendment_state) { "draft" }

        context "and the user is NOT the amender" do
          let(:user) { other_user }

          it "redirects to 404" do
            expect do
              post :publish_draft, params: params.merge(
                emendation_params:,
                amendable_params:
              )
            end.to raise_error(ActionController::RoutingError)
          end
        end
      end

      context "when the user is the amender" do
        let(:user) { amendment.amender }

        context "and the amendment is NOT a draft" do
          it "redirects to 404" do
            expect do
              post :publish_draft, params: params.merge(
                emendation_params:,
                amendable_params:
              )
            end.to raise_error(ActionController::RoutingError)
          end
        end

        context "and the amendment is a draft" do
          let(:amendment_state) { "draft" }

          it "publishes the draft" do
            post :publish_draft, params: params.merge(
              emendation_params:,
              amendable_params:
            )
            expect(flash[:notice]).to eq("Amendment successfully published.")
          end
        end
      end
    end
  end
end
