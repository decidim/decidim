/*
  Stimulus Webpack Helpers 1.0.0
  Copyright © 2021 Basecamp, LLC
  This is just a copy of @hotwired/stimulus-webpack-helpers functionality.
  In order to have our own structure, we need to replace the Regex from identifierForContextKey method
 */

const identifierForContextKey = function(key, excludes = []) {
  const logicalName = (key.match(/^(?:\.\/)?(.+)(?:\/controller\..+?)$/) || [])[1];

  if (logicalName && excludes.includes(logicalName)) {
    return null;
  }

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

const definitionForModuleWithContextAndKey = function(context, key, excludes = []) {
  const identifier = identifierForContextKey(key, excludes);

  if (identifier) {
    return definitionForModuleAndIdentifier(context(key), identifier);
  }
  return null;
}

const definitionsFromContext = function(context, excludes = []) {
  return context.keys().
    map((key) => definitionForModuleWithContextAndKey(context, key, excludes)).
    filter((value) => value);
}

export { definitionForModuleAndIdentifier, definitionForModuleWithContextAndKey, definitionsFromContext, identifierForContextKey };
