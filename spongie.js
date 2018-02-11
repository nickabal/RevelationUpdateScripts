var page = require('webpage').create();
page.settings.userAgent = 'Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101 Firefox/52.0';

page.open('https://www.spongepowered.org/downloads/spongeforge/stable/1.12.2', function (status) {
    if (status !== 'success') {
        console.log('Unable to load the address!');
        phantom.exit(1);
    } else {
        window.setTimeout(function () {
	    latest_download_link = page.content.match(/Latest<[<\/>a-z0-9]*[ ]?[<\/>a-z0-9]*[ ]?["=<\/>a-z0-9]*<a href="https:\/\/repo.spongepowered.org\/maven\/org\/spongepowered\/spongeforge\/[.A-Z-0-9]*\/spongeforge[.A-Z-0-9]*.jar"/)[0].match(/https:\/\/repo.spongepowered.org\/maven\/org\/spongepowered\/spongeforge\/[.A-Z-0-9]*\/spongeforge[.A-Z-0-9]*.jar/)[0];
	    console.log(latest_download_link);
            phantom.exit(0);
        }, 5000); // Change timeout as required to allow sufficient time 
    }
});


