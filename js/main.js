document.addEventListener("DOMContentLoaded", function() {
    
    // Determine the base path based on where the user is
    // If we are in the root (index.html), path is "./"
    // If we are in /pages/, path is "../"
    const isRoot = window.location.pathname.endsWith("index.html") || window.location.pathname.endsWith("/");
    const basePath = isRoot ? "" : "../";

    function loadComponent(elementId, filePath) {
        const element = document.getElementById(elementId);
        if (!element) return;

        // Add base path to the file path
        const fullPath = basePath + filePath;

        fetch(fullPath)
            .then(response => {
                if (!response.ok) {
                    throw new Error(`Could not find file: ${fullPath} (Status: ${response.status})`);
                }
                return response.text();
            })
            .then(data => {
                element.innerHTML = data;
                
                // If it's the header, highlight the active link
                if(elementId === "header-placeholder") {
                    highlightActiveLink();
                    fixImagePaths(element); // Fix logo path relative to current page
                }
                if(elementId === "footer-placeholder") {
                    fixImagePaths(element);
                }
            })
            .catch(error => {
                console.error('Error loading component:', error);
                element.innerHTML = `<div class="alert alert-danger">Error loading ${filePath}. check console.</div>`;
            });
    }

    function highlightActiveLink() {
        const currentPath = window.location.pathname;
        const navLinks = document.querySelectorAll('.nav-link');

        navLinks.forEach(link => {
            let linkHref = link.getAttribute('href');
            // Clean up href for comparison
            if (linkHref.startsWith("..")) linkHref = linkHref.substring(2);
            if (linkHref.startsWith("/")) linkHref = linkHref.substring(1);
            
            if (currentPath.includes(linkHref) && linkHref !== "" && linkHref !== "#") {
                link.classList.add('active');
                link.classList.add('text-primary');
            }
        });
    }

    // Helper: Fix image src paths depending on if we are in /pages/ or root
    function fixImagePaths(container) {
        if (isRoot) return; // No fix needed for root
        
        const images = container.querySelectorAll('img');
        images.forEach(img => {
            const src = img.getAttribute('src');
            // If image path starts with assets/ or /assets/, prepend ../
            if (src.startsWith('assets/') || src.startsWith('/assets/')) {
                const cleanSrc = src.startsWith('/') ? src.substring(1) : src;
                img.setAttribute('src', '../' + cleanSrc);
            }
        });
    }

    // Load components using relative paths (No leading slash)
    loadComponent("header-placeholder", "components/header.html");
    loadComponent("footer-placeholder", "components/footer.html");
});
