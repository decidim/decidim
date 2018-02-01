module AdminAbilityExtend
  can :authorize, Comment
end

Decidim::Comments::Abilities::AdminAbility.class_eval do
  prepend(AdminAbilityExtend)
end

