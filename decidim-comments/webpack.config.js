const path = require('path');

module.exports = {
    entry: './app/frontend/entry.js',
    output: {
        path: path.join(__dirname, 'app/assets/javascripts'),
        filename: 'bundle.js'
    },
    resolve: {
        extensions: ['', '.js', '.jsx', '.graphql', '.yml']
    },
    module: {
        noParse: [
          /\/sinon\.js/
        ],
        loaders: [
            { 
                test: /\.jsx?$/,
                exclude: /node_modules/,
                loaders: ['babel', 'eslint'] 
            },
            {
                test: /\.(graphql|gql)$/,
                exclude: /node_modules/,
                loaders: ['raw']
            },
            {
                test: /\.(jpg|png)$/,
                loader: 'url'
            },
            {
                test: /\.(yml|yaml)$/,
                loaders: ['json', 'yaml']
            },
            { 
                test: require.resolve("react"),
                loader: "expose?React"
            },
            { 
                test: require.resolve("react-dom"),
                loader: "expose?ReactDOM"
            }
        ]
    },
    externals: {
        'cheerio': 'window',
        'react/lib/ExecutionEnvironment': true,
        'react/lib/ReactContext': true,
        'react/addons': true
    }
};

      