# frozen_string_literal: true

module Decidim
  module Votings
    module Census
      module Admin
        # A form object used to create a datum record (participant) for
        # a voting census
        class DatumForm < Form
          mimic :datum

          include Decidim::Votings::Census::CheckFields

          attribute :full_name, String
          attribute :full_address, String
          attribute :mobile_phone_number, String
          attribute :email, String
          attribute :ballot_style_code, String

          validates :birthdate, format: { with: /\A\d{8}\z/ }

          validates :full_name,
                    :full_address,
                    :birthdate,
                    presence: true

          def ballot_style_code
            @ballot_style_code&.upcase
          end
        end
      end
    end
  end
end
