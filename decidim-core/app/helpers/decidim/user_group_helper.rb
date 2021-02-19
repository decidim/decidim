# frozen_string_literal: true

module Decidim
  module UserGroupHelper
    # Renders a user_group select field in a form.
    # form - FormBuilder object
    # name - attribute user_group_id
    # options - A hash used to modify the behavior of the select field.
    #
    # Returns nothing.
    def user_group_select_field(form, name, options = {})
      user_groups = Decidim::UserGroups::ManageableUserGroups.for(current_user).verified
      form.select(
        name,
        user_groups.map { |g| [g.name, g.id] },
        selected: @form.user_group_id.presence,
        include_blank: current_user.name,
        label: options.has_key?(:label) ? options[:label] : true
      )
    end
  end
end
