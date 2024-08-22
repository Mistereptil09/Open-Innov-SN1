const express = require('express');
const webpack = require('webpack');
const searchRoutes = require('./api/searchRoutes');
const webpackDevMiddleware = require('webpack-dev-middleware');
const path = require('path');
const webpackHotMiddleware = require('webpack-hot-middleware');
const config = require('./webpack.config.js');
const compiler = webpack(config);
require('dotenv').config();
const router = express.Router();

const PORT = process.env.PORT || 3000;
const app = express();

// Set the view engine to ejs
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, './src/views'));

// Use the Webpack dev middleware
app.use(
    webpackDevMiddleware(compiler,{
        publicPath: config.output.publicPath,
    })
);

// Serve the static files from the dist directory (only necessary for production builds)
app.use(express.static(path.join(__dirname, 'dist')));

// Use the Webpack hot middleware
app.use(webpackHotMiddleware(compiler));

// Routes
app.get('/', (req, res) => {
    res.render('index', { title: 'Home' });
});

app.get('/players', (req, res) => {
    res.render('players', { title: 'Players' });
});

app.get('/teams', (req, res) => {
    res.render('teams', { title: 'Teams' });
});

// Route to render individual player stats
router.get('/playerStats/:id', async (req, res) => {
    const player = await Player.findById(req.params.id);
    if (!player) {
        return res.status(404).send('Player not found');
    }
    res.render('playerStats', { player });
});


app.use(express.json());
app.use('/api', searchRoutes);

// Error handling
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).send('Something broke!');
});

// 404 Handling
app.use((req, res, next) => {
    res.status(404).send('Sorry, we could not find that!');
});

// Start the server
app.listen(PORT, function () {
    console.log('Server running : http://localhost:' + PORT);
});