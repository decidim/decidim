# frozen_string_literal: true

module Decidim
  module Votings
    # A command to check if census data is given
    class CheckCensus < Rectify::Command
      def initialize(form)
        @form = form
      end

      # Executes the command. Broadcast this events:
      # - :ok when census is found
      # - :invalid when the form is not valid
      # - :not_found when census is not found
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless form.valid?

        check_census
      end

      attr_reader :form, :session

      def check_census
        if Decidim::Votings::Census::Datum.exists?(dataset: form.current_participatory_space.dataset, hashed_check_data: form.hashed_check_data)
          datum = Decidim::Votings::Census::Datum.find_by(dataset: form.current_participatory_space.dataset, hashed_check_data: form.hashed_check_data)
          broadcast(:ok, datum)
        else
          broadcast(:not_found)
        end
      end
    end
  end
end
