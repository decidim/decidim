# module CurrentUserAbilityExtend
#   def voting_enabled?
#     return unless current_settings
#     (current_settings.votes_enabled? || current_settings.votes_weight_enabled?) && !current_settings.votes_blocked?
#   end
# end

# Decidim::Proposals::Abilities::CurrentUserAbility.class_eval do
#   prepend(CurrentUserAbilityExtend)
# end
