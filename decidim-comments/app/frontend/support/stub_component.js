/* eslint-disable no-param-reassign */
const stubComponent = function(componentClass) {
  let originalPropTypes = {};
  let originalFragments = {};

  beforeEach(function() {
    originalPropTypes = componentClass.propTypes;
    originalFragments = componentClass.fragments;

    componentClass.propTypes = {};
    componentClass.fragments = {};
  });

  afterEach(function() {
    componentClass.propTypes = originalPropTypes;
    componentClass.fragments = originalFragments;
  });
};

export default stubComponent;
