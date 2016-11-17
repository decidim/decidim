module.exports = {
    entry: './app/frontend/entry.js',
    output: {
        path: __dirname + '/app/assets/javascripts',
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
            },
            /*{
                test: /\.css$/,
                loaders: [
                    'style?sourceMap',
                    'css?modules&importLoaders=1&localIdentName=[path]___[name]__[local]___[hash:base64:5]'
                ]
            }*/
        ]
    }
};
