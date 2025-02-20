const path = require('path');

module.exports = {
    mode: 'development',
    entry: path.resolve(__dirname, '_build/default/client/output/client/ReactApp.js'),
    output: {
        filename: 'main.js',
        path: path.resolve(__dirname, 'static/js'),
    },
    module: {
        rules: [
            {
                test: /\.css$/,
                use: [
                    'style-loader',
                    'css-loader',
                    'postcss-loader'
                ],
            },
        ],
    },
};
