# frozen_string_literal: true

module Decidim
  # This concern contains the logic related to nicknames.
  module Nicknamizable
    #
    # Allowed range for nickname length
    #
    def nickname_length_range
      (0...nickname_max_length)
    end

    #
    # Maximum allowed nickname length
    #
    def nickname_max_length
      20
    end

    #
    # Converts any string into a valid nickname
    #
    # * Parameterizes it so it's valid as a URL.
    # * Trims length so it fits validation constraints.
    # * Disambiguates it so it's unique.
    #
    def nicknamize(name)
      disambiguate(name.parameterize(separator: "_")[nickname_length_range])
    end

    private

    def disambiguate(name)
      candidate = name

      2.step do |n|
        return candidate unless exists?(nickname: candidate)

        candidate = clon(candidate, n)
      end
    end

    def clon(candidate, number)
      appendix = "_#{number}"

      "#{candidate[0...(nickname_max_length - appendix.length)]}#{appendix}"
    end
  end
end
