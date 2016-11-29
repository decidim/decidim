/* eslint-disable no-param-reassign */
const stubComponent = function(componentClass, options = {}) {
  let originalPropTypes = {};
  let originalFragments = {};

  beforeEach(function() {
    originalPropTypes = componentClass.propTypes;
    originalFragments = componentClass.fragments;

    componentClass.propTypes = options.propTypes || {};
    componentClass.fragments = options.fragments || {};
  });

  afterEach(function() {
    componentClass.propTypes = originalPropTypes;
    componentClass.fragments = originalFragments;
  });
};

export default stubComponent;
