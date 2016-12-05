// ---------------------------------------
// Test Environment Setup
// ---------------------------------------
import sinon            from 'sinon/pkg/sinon';
import chai             from 'chai';
import sinonChai        from 'sinon-chai';
import chaiAsPromised   from 'chai-as-promised';
import chaiEnzyme       from 'chai-enzyme';
import loadTranslations from './support/load_translations';
import requireAll       from './support/require_all';

// 
chai.use(sinonChai)
chai.use(chaiAsPromised)
chai.use(chaiEnzyme())
// 
global.chai = chai
global.sinon = sinon
global.expect = chai.expect
global.should = chai.should()

// ---------------------------------------
// Require Tests
// ---------------------------------------
requireAll(require.context('./application/', true, /\.test\.jsx?$/));
requireAll(require.context('./comments/', true, /\.test\.jsx?$/));

// Load component locales from yaml files
loadTranslations();
