# frozen_string_literal: true

# Add additional ransacker functionality to category model.

# Categories serve as a taxonomy for components to use for while in the
# context of a participatory process.
Decidim::Category.class_eval do
  # Allow ransacker to search for a key in a hstore column (`name`.`en`)
  ransacker :name do |parent|
    Arel::Nodes::InfixOperation.new("->>", parent.table[:name], Arel::Nodes.build_quoted(I18n.locale.to_s))
  end
end
