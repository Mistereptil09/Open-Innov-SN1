export async function search() {
    const searchButton = document.getElementById('searchButton'); // script is called if this element exists so no need to check
    searchButton.addEventListener('click', async () => {

        // Check if elements exist before accessing their values
        let searchInputElement = document.getElementById('searchInput');
        let sortListElement = document.getElementById('sortList');
        let selectedPositionElement = document.getElementById('selectedPosition');
        let searchTargetElement = document.getElementById('searchTarget');
        let resultsElement = document.getElementById('results');
        
        let searchInputValue = searchInputElement ? searchInputElement.value : undefined;
        let sortList = sortListElement ? sortListElement.value : undefined;
        let selectedPosition = selectedPositionElement ? selectedPositionElement.value : undefined;
        let searchTarget = searchTargetElement ? searchTargetElement.value : undefined;
        

        if (searchTarget && searchTarget === 'teams' || searchTarget === 'players' && searchInputValue) {
            let result = await sendSearchRequest(searchInputValue, sortList, selectedPosition, searchTarget);
            console.log('Search successful:');

            if (resultsElement) {
                // Clear previous results
                resultsElement.innerHTML = searchInputValue ? `<h2>Results for "${searchTarget}" with "${searchInputValue}"</h2>` : '';

                // Process and display the player information
                result.forEach(player => {
                    let birth_date = new Date(player.birth_date);
                    let formattedBirthDate = `${birth_date.getMonth() + 1}/${birth_date.getDate()}/${birth_date.getFullYear()}`;
                    let playerInfo = `
                        <div class="player">
                            <p><strong>Name:</strong> ${player.name}</p>
                            <p><strong>Birth Date:</strong> ${formattedBirthDate}</p>
                            <p><strong>Weight:</strong> ${player.weight} pounds</p>
                            <p><strong>Height:</strong> ${player.height} feets</p>
                            <p><strong>Origin:</strong> ${player.origin}</p>
                        </div>
                        <hr>
                    `;
                    resultsElement.innerHTML += playerInfo;
                });
            }
            else {
                console.error('No results element found\n unable to display results');
            }
        }
        else {
            if (!searchInputValue) {
                console.error('Invalid search input:', searchInputValue);
                // Display error message next to the search input
            }
            else if (!searchTarget) {
                console.error('Invalid search target:', searchTarget);
                // Display error message next to the search target
            }
            else if (searchTarget !== 'teams' || searchTarget !== 'players') {
            }
            else {
                console.error('Unknown error:', searchInputValue, searchTarget);
            }
        }

    });
}


async function sendSearchRequest(keyword, sort, selectedPosition, searchTarget) {
    console.log('sendSearchRequest:', keyword, sort, selectedPosition, searchTarget);
    let queryString = `/api/search-${searchTarget}?keyword=${encodeURIComponent(keyword)}`;
    if (sort) {
        queryString += `&sort=${encodeURIComponent(sort)}`;
    }
    if (selectedPosition) {
        queryString += `&selectedPosition=${encodeURIComponent(selectedPosition)}`;
    }
    try {
        const response = await fetch(queryString);
        if (!response.ok) {
            throw new Error('Network response was not ok', '\n'+response.statusText);
        }
        const results = await response.json();
        return results;
    }
    catch (error) {
        console.error('Error searching:', error);
        return [];
    }
};
