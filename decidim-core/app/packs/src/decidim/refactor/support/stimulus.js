/*
  Stimulus Webpack Helpers 1.0.0
  Copyright © 2021 Basecamp, LLC
  This is just a copy of @hotwired/stimulus-webpack-helpers functionality.
  In order to have our own structure, we need to replace the Regex from identifierForContextKey method
 */

const identifierForContextKey = function(key) {
  const logicalName = (key.match(/^(?:\.\/)?(.+)(?:\/controller\..+?)$/) || [])[1];
  
  if (logicalName) {
    return logicalName.replace(/_/g, "-").replace(/\//g, "--");
  }
  return null;
}

const definitionForModuleAndIdentifier = function(module, identifier) {
  const controllerConstructor = module.default;
  if (typeof controllerConstructor === "function") {
    return { identifier, controllerConstructor };
  }
  return null;
}

const definitionForModuleWithContextAndKey = function(context, key) {
  const identifier = identifierForContextKey(key);
  if (identifier) {
    return definitionForModuleAndIdentifier(context(key), identifier);
  }
  return null;
}

const definitionsFromContext = function(context) {
  return context.keys().
    map((key) => definitionForModuleWithContextAndKey(context, key)).
    filter((value) => value);
}

export { definitionForModuleAndIdentifier, definitionForModuleWithContextAndKey, definitionsFromContext, identifierForContextKey };
