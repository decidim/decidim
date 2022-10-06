# frozen_string_literal: true

# Helpers that get automatically included in system specs.
module DateTimeHelpers
  # Note that the Decidim datetime selector UI only supports minutes intervals
  # of 5 but when using the programming API exposed by foundation-datepicker,
  # it can be set to any date.
  def fill_in_datetime(field_id, value)
    # The value needs to be passed without the timezone to the view for it to
    # work properly. Otherwise it is selecting the GMT time and the specs won't
    # work if the browser environment is running in some other timezone.
    formatted_value = value.strftime("%Y-%m-%dT%H:%M")
    page.execute_script(
      <<~JS
        // Uses the foundation-datepicker API to set the date/time.
        // This also supports times that Decidim does not allow the user to
        // pick from the UI.
        var datepicker = $("##{field_id}").data("datepicker");
        datepicker.setDate(new Date("#{formatted_value}"));
      JS
    )
  end
end

RSpec.configure do |config|
  config.include DateTimeHelpers, type: :system
end
