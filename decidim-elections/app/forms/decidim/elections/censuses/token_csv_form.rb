# frozen_string_literal: true

module Decidim
  module Elections
    module Censuses
      # This class presents data for logging into the system with census data.
      class TokenCsvForm < Decidim::Form
        attribute :email, String
        attribute :token, String

        validates :email, presence: true
        validates :token, presence: true

        validate :data_in_census

        def voter_uid
          @voter_uid ||= election.census.users(election).find_by("data->>'email' = :email, data-->'token' = :token", email: email.strip.downcase,
                                                                                                                     token: token.strip)&.to_global_id&.to_s
        end

        def election
          @election ||= context.election
        end

        private

        def data_in_census
          return if voter_uid.present?

          errors.add(:base, I18n.t("decidim.elections.censuses.token_csv_form.invalid"))
        end
      end
    end
  end
end
