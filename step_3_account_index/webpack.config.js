const path = require('path');
const devMode = process.env.NODE_ENV !== 'production'
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const OptimizeCSSAssetsPlugin = require("optimize-css-assets-webpack-plugin");
const postcssPresetEnv = require('postcss-preset-env');
const UglifyJsPlugin = require('uglifyjs-webpack-plugin');

module.exports = {
  entry: './src/index.js',
  output: {
    filename: 'archive.js',
    path: path.resolve(__dirname, 'dist')
  },
  optimization: {
    minimizer: [
      new UglifyJsPlugin({
        cache: true,
        parallel: true,
        sourceMap: true // set to true if you want JS source maps
      }),
      new OptimizeCSSAssetsPlugin({})
    ]
  },
  plugins: [
    new MiniCssExtractPlugin({
      filename: devMode ? "[name].css" : '[name].[hash].css',
      chunkFilename: devMode ? "[id].css" : '[id].[hash].css'
    })
  ],
  module: {
    rules: [
      {
        test: /\.m?js$/,
        exclude: /(node_modules|bower_components)/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['@babel/preset-env']
          }
        }
      },
      // {
      //   test: / ?\.(sa|sc|c)ss$/,
      //   exclude: /node_modules/,
      //   use: [
      //     devMode ? 'style-loader' : MiniCssExtractPlugin.loader,
      //     {
      //       loader: 'css-loader',
      //       options: {
      //         importLoaders: 1,
      //       }
      //     },
      //     {
      //       loader: 'postcss-loader',
      //       options: {
      //         ident: 'postcss',
      //         plugins: () => [
      //           postcssPresetEnv()
      //         ]
      //       }
      //     },
      //     'sass-loader'
      //   ]
      // },
      // {
      //     test: /\.(png|jp(e*)g|svg)$/,
      //     use: [{
      //         loader: 'url-loader',
      //         options: {
      //             limit: 8000, // Convert images < 8kb to base64 strings
      //             name: 'images/[hash]-[name].[ext]'
      //         }
      //     }]
      // },
      // {
      //   test: /\.html$/,
      //   use: [
      //     {
      //       loader: 'mustache-loader'
      //     },
      //     {
      //       loader: 'html-loader',
      //       options: {
      //         interpolate: true
      //       }
      //     }
      //   ]
      // }
    ]
  }
}
