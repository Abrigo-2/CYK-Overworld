const navigation = document.querySelector(".nav-sidebar ul");

function createSideBarItems(isIndexPage, currentPage) {
    navigation.innerHTML = '';
    console.log(navigation.nodeName)

    
    function addHeader(name, page) {
        const listItem = document.createElement("li")
        
        // This simply makes a divider line.
        if (name === "-"){
            const dividerLine = document.createElement("hr");
            dividerLine.style = "margin-top:-2.5px;margin-bottom:2.5px;" ;
            navigation.appendChild(dividerLine) 
            return
        
        // The current page doesn't get a link, just a greyed out text.
        } else if (page === currentPage) {
            listItem.className = "active";
            listItem.style = "margin-left:5px;";

            listItem.textContent = "> " + name + " <";
        // Correct the documentation's page location.
        } else if (page === "documentation.html"){
            const linkedPage = document.createElement("a");
            linkedPage.textContent = name;
            linkedPage.href = page;
            if (!isIndexPage) {
                linkedPage.href = "../" + page;
            }
            listItem.appendChild(linkedPage);
        } else {
            const linkedPage = document.createElement("a");
            linkedPage.textContent = name;
            
            // Specify the pages folder.
            linkedPage.href = page;
            if (isIndexPage) {
                linkedPage.href = "pages/" + page;
            }
            listItem.appendChild(linkedPage);
        }

        navigation.appendChild(listItem) 
    }

    const headerUGuide = document.createElement("li");
    headerUGuide.textContent = "Setup and Usage Guide";
    headerUGuide.className = "li-header";
    navigation.appendChild(headerUGuide)
    addHeader("Welcome", "documentation.html" )
    addHeader("Keyboard Controls", "controls.html" )
    addHeader("Understanding your Files and Directories", "basic.html" )
    addHeader("How to read this documentation", "howtoread.html" )
    addHeader("Special Variables", "variables.html" )
    addHeader("Terminology", "terms.html" )
    addHeader("Game events", "api-events.html" )
    addHeader("Working with CYF's Scripts", "api-functions-script.html" )
    addHeader("-", "-" )

    const headerProperDocs = document.createElement("li");
    headerProperDocs.textContent = "Pinpoint Reference";
    headerProperDocs.className = "li-header";
    navigation.appendChild(headerProperDocs)
    addHeader("Text commands", "api-text.html" )
    addHeader("Misc. Functions", "api-functions-main.html" )
    addHeader("The Player('s Soul) Object", "api-functions-player.html" )
    addHeader("The Entity Object", "api-functions-entity.html" )
    addHeader("The Audio Object", "api-functions-audio.html" )
    addHeader("The NewAudio Object", "api-functions-newaudio.html" )
    addHeader("-", "-" )
    addHeader("The Input Object", "api-functions-input.html" )
    addHeader("Key List", "cyf-keys.html" )
    addHeader("-", "-" )
    addHeader("The Time Object", "api-functions-time.html" )
    addHeader("The Misc Object", "api-functions-misc.html" )
    addHeader("Camera and Screen Functions", "api-functions-camera.html" )
    addHeader("Items and Inventory", "cyf-inventory.html" )
    addHeader("-", "-" )
    addHeader("Wave Scripts", "api-functions-waves.html" )
    addHeader("Projectile management", "api-projectile.html" )
    addHeader("The Pixel-Perfect Collision System", "cyf-ppcollision.html" )
    addHeader("-", "-" )
    addHeader("Working with Sprites", "api-animation.html" )
    addHeader("-", "-" )
    

}
