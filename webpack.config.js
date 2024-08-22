const path = require('path');
const MiniCssExtractPlugin = require('mini-css-extract-plugin'); // Add this line
const webpack = require('webpack');
const { split } = require('lodash');

module.exports = {
  mode: 'development',
  entry: './src/scripts/index.js', // Entry point
  output: {
    filename: '[name].js',
    path: path.resolve(__dirname, 'dist'),
    clean: true,
    publicPath: '/',
  },
  optimization: {
    splitChunks: {
      chunks: 'all', // Split all chunks
    },
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
        },
      },
      {
        test: /\.css$/,
        use: [
          MiniCssExtractPlugin.loader, // Extract CSS into separate files
          'css-loader', // Translates CSS into CommonJS
        ],
      },
      {
        test: /\.(png|jpe?g|gif|svg|ico)$/i,
        use: [
          {
            loader: 'file-loader',
            options: {
              name: '[name].[hash].[ext]',
              outputPath: 'assets/images',
            },
          },
        ],
      },
    ],
  },
  plugins: [
    new MiniCssExtractPlugin({ // This plugin extracts CSS into separate files
      filename: '[name].css',
      chunkFilename: '[id].css',
    }),
  ],
};