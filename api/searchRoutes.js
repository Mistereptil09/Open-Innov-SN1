const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client'); // Ensure PrismaClient is imported
const prisma = new PrismaClient(); // Instantiate PrismaClient
const validator = require('validator');


// Search for teams in the database
async function searchTeams(keyword, sortParams) {
    const query = {
        where: {
            name: {
                contains: keyword
            }
        }
    };

    // Conditionally add sort parameters
    if (sortParams && sortParams !== undefined) {
        query.orderBy = sortParams;
    }

    // Query the database
    console.log('searchTeams query:', query);
    const teams = await prisma.teams.findMany(query);
    return teams;
};

// Search routes
router.get('/search-teams', async (req, res) => {
    console.log('search-teams:', req.query);
    const { keyword } = req.query;
    const { sort } = req.query;

    // Validate and sanitize input
    if (!keyword || !validator.isAlphanumeric(keyword)) {
        return res.status(400).json({ error: 'Invalid keyword' });
    }
    // Query the database
    try {
        sort ? sort : sort = 'none';
        const teams = await searchTeams(keyword, sort);
        res.json(teams);
        console.log('Teams:', teams);
    } catch (error) {
        console.error('Error searching teams:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});


// Search for players in the database
async function searchPlayers(keyword, sortParams, selectedPosition) {
    const query = {
        where: {
            name: {
                contains: keyword
            }
        }
    };

    // Conditionally add position filter
    if (selectedPosition && selectedPosition !== undefined) {
        query.include = {PlayerTeam: true};
        query.where.PlayerTeam = {position_id: selectedPosition};
    }
    // Conditionally add sort parameters
    if (sortParams && sortParams !== undefined) {
        query.orderBy = sortParams;
    }

    // Query the database
    console.log('searchPlayers query:', query);
    const players = await prisma.players.findMany(query);

    return players;
}

// Search for players
router.get('/search-players', async (req, res) => {
    console.log('search-players:', req.query);
    const { keyword } = req.query;
    const { sort } = req.query;
    const { selectedPosition } = req.query;

    // Validate and sanitize input
    if (!keyword || !validator.isAlphanumeric(keyword)) {
        return res.status(400).json({ error: 'Invalid keyword' });
    }
    // Query the database
    try {
        const players = await searchPlayers(keyword, sort, selectedPosition);
        res.json(players);
        console.log('Players:', players);
    } catch (error) {
        console.error('Error searching players:', error);
        res.status(500).json({ error: 'Error server error' });
    }
});


// Gracefully shut down the PrismaClient
process.on('SIGINT', async () => {
    await prisma.$disconnect();
    process.exit(0);
});


module.exports = router;