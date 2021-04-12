# frozen_string_literal: true

module Decidim
  module Votings
    module PollingOfficerZone
      # Space to manage the elections for a Polling Station Officer
      class VotesController < Decidim::Votings::PollingOfficerZone::ApplicationController
        include FormFactory

        helper_method :polling_station, :in_person_form, :datum,
                      :form_title, :button_text,
                      :questions
        helper Decidim::Admin::IconLinkHelper

        def new
        end

        def create
          if in_person_form.voted?
            flash[:notice] = I18n.t("votes.create.success", scope: "decidim.votings.polling_officer_zone")
            return redirect_to new_polling_officers_polling_station_vote_path(polling_station)
          end
          render :new
        end

        def show
          enforce_permission_to :view, :polling_station, polling_officers: polling_officers
        end

        private

        def polling_station
          @polling_station ||= Decidim::Votings::PollingStation.find(params[:polling_station_id])
        end

        def in_person_form
          @in_person_form ||= form(Decidim::Votings::Census::InPersonForm).from_params(params)
        end

        def datum
          return unless request.post? && in_person_form.valid?

          @datum ||= Decidim::Votings::Census::Datum.find_by(hashed_in_person_data: in_person_form.hashed_in_person_data)
        end

        def form_title
          @form_title ||= if in_person_form.verified?
                            ".questions_title"
                          elsif datum.present?
                            ".verify_title"
                          else
                            ".form_title"
                          end
        end

        def button_text
          @button_text ||= if in_person_form.verified?
                             ".complete_voting"
                           elsif datum.present?
                             ".verify_document"
                           else
                             ".validate_document"
                           end
        end

        def questions
          # TO-DO: use selected election after refactoring this controller
          @questions ||= Decidim::Elections::Election.where(
            decidim_component_id: polling_station.voting.components.where(manifest_name: :elections).pluck(:id)
          ).last.questions
        end
      end
    end
  end
end
