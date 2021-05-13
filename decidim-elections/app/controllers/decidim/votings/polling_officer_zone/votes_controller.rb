# frozen_string_literal: true

module Decidim
  module Votings
    module PollingOfficerZone
      # Space to manage the elections for a Polling Station Officer
      class VotesController < Decidim::Votings::PollingOfficerZone::ApplicationController
        include FormFactory

        helper_method :polling_station, :in_person_form, :datum,
                      :form_title, :button_text,
                      :questions, :polling_officer, :election
        helper Decidim::Admin::IconLinkHelper

        def new; end

        def create
          if in_person_form.voted?
            flash[:notice] = I18n.t("votes.create.success", scope: "decidim.votings.polling_officer_zone")
            return redirect_to new_polling_officer_election_vote_path(polling_officer, election)
          end
          render :new
        end

        def show
          enforce_permission_to :view, :polling_station, polling_officers: polling_officers
        end

        private

        def polling_station
          @polling_station ||= polling_officer.polling_station
        end

        def election
          @election ||= Decidim::Elections::Election.find(params[:election_id])
        end

        def polling_officer
          @polling_officer ||= Decidim::Votings::PollingOfficer.find(params[:polling_officer_id])
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
                            I18n.t("votes.new.questions_title", scope: "decidim.votings.polling_officer_zone")
                          elsif datum.present?
                            I18n.t("votes.new.verify_title", scope: "decidim.votings.polling_officer_zone")
                          else
                            I18n.t("votes.new.form_title", scope: "decidim.votings.polling_officer_zone")
                          end
        end

        def button_text
          @button_text ||= if in_person_form.verified?
                             I18n.t("votes.new.complete_voting", scope: "decidim.votings.polling_officer_zone")
                           elsif datum.present?
                             I18n.t("votes.new.verify_document", scope: "decidim.votings.polling_officer_zone")
                           else
                             I18n.t("votes.new.validate_document", scope: "decidim.votings.polling_officer_zone")
                           end
        end

        def questions
          @questions ||= election.questions
        end
      end
    end
  end
end
