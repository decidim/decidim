const path = require('path');

module.exports = {
    entry: './app/frontend/entry.js',
    output: {
        path: path.join(__dirname, 'app/assets/javascripts'),
        filename: 'bundle.js'
    },
    resolve: {
        extensions: ['', '.js', '.jsx']
    },
    module: {
        loaders: [
            { 
                test: /\.jsx?$/,
                exclude: /node_modules/,
                loaders: ['babel', 'eslint'] 
            }
        ]
    }
};
