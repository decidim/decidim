# frozen_string_literal: true

# Add additional ransacker functionality to scope model.

# Scopes are used in some entities through Decidim to help users know which is
# the scope of a participatory process.
# (i.e. does it affect the whole city or just a district?)
Decidim::Scope.class_eval do
  # Allow ransacker to search for a key in a hstore column (`name`.`en`)
  ransacker :name do |parent|
    Arel::Nodes::InfixOperation.new("->>", parent.table[:name], Arel::Nodes.build_quoted(I18n.locale.to_s))
  end
end
