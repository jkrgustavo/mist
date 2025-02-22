const path = require('path');

module.exports = {
    mode: 'development',
    entry: path.resolve(__dirname, '_build/default/client/output/client/ReactApp.js'),
    output: {
        filename: 'main.js',
        path: path.resolve(__dirname, 'static/js'),
    },
    resolve: {
        alias: {
            '@': path.resolve(__dirname, './client/shadcn/'),
        },
        extensions: ['.js', '.jsx', '.re', '.ts', '.tsx'],
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
            {
                test: /\.(js|jsx|ts|tsx)$/,
                exclude: /node_modules/,
                use: {
                    loader: 'babel-loader',
                    options: {
                        presets: [
                            '@babel/preset-env', 
                            '@babel/preset-react', 
                            '@babel/preset-typescript'
                        ],
                    },
                },
            }
        ],
    },
};
