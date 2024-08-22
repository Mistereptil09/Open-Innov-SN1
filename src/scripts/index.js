// Importing styles
import '../styles/stylesheet.css';
// Importing images

document.addEventListener('DOMContentLoaded', () => {
    console.log('DOMContentLoaded');
    // dynamic import
    if (document.getElementById('searchButton')) {
        import('./search') // Import the search module
            .then(module => {
                module.search(); // Call the search function
            })
            .catch(error => {
                console.error('Error importing search:', error);
            })
    }
});