# frozen_string_literal: true

#
# Overwrite Virtus default behaviour when coercing a String into a Date so that
# we have the ability to use localized date formats.
#
module Coercible
  class Coercer
    # Coerce String values
    class String < Object
      def to_date(value)
        # NOTE: The used format should be the same than the one used by
        # the user (manual date entry) and the datepicker widget in the UI.
        return value if value.blank?
        ::Date.strptime(value, I18n.t("date.formats.decidim_short"))
      end
    end
  end
end
