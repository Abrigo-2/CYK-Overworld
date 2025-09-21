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

    function addSectionHeader (section) {
        const sectionHeader = document.createElement("li");
        sectionHeader.textContent = section;
        sectionHeader.className = "li-header";
        navigation.appendChild(sectionHeader)
    }

    
    addSectionHeader( "Setup and Usage Guide")
    addHeader("Welcome", "documentation.html" )
    addHeader("Keyboard Controls", "controls.html" )
    addHeader("Understanding your Files and Directories", "basic.html" )
    addHeader("How to read this documentation", "howtoread.html" )
    addHeader("Engine and Debugging tools", "debugging.html" )
    addHeader("Setting up the Encounter files", "encounters.html" )
    addHeader("Game events", "api-events.html" )
    addHeader("Working with CYF's Scripts", "api-functions-script.html" )
    addHeader("-", "-" )

    addSectionHeader( "Pinpoint Reference")
    addHeader("Text Objects", "cyf-text.html" )
    addHeader("In-line Text effects", "api-text.html" )
    addHeader("Working with Sprites", "api-animation.html" )
    addHeader("-", "-" )

    addHeader("The Audio Object", "api-functions-audio.html" )
    addHeader("The NewAudio Object", "api-functions-newaudio.html" )
    addHeader("-", "-" )

    addHeader("The Input Object", "api-functions-input.html" )
    addHeader("Key List", "cyf-keys.html" )
    addHeader("-", "-" )

    addSectionHeader( "Player and Monster Entities")
    addHeader("Entities, broadly speaking.", "api-functions-entity.html" )
    addHeader("Player Entities", "api-functions-entity.html" )
    addHeader("Monster Entities", "api-functions-entity.html" )
    addHeader("-", "-" )

    addSectionHeader( "Miscelaneous")
    addHeader("Misc. Functions", "api-functions-main.html" )
    addHeader("The Time Object", "api-functions-time.html" )
    addHeader("Program's Window and Machine functions", "api-functions-windows.html" )
    addHeader("Camera and Screen functions", "api-functions-camera.html" )
    addHeader("Items and Inventory", "cyf-inventory.html" )
    addHeader("-", "-" )

    addSectionHeader( "DEFENDING phase, Arena and Bullets")
    addHeader("Wave Scripts", "waves.html" )
    addHeader("The Player('s Soul) Object", "waves-player.html" )
    addHeader("The Bullet-Hell Arena", "waves-arena.html" )
    addHeader("Creating and Handling Bullets", "waves-bullet.html" )
    addHeader("The Pixel-Perfect Collision System", "cyf-ppcollision.html" )
    addHeader("-", "-" )
    

}
