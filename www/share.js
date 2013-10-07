var asciiArtTextString = "";

function sendAsciiArtAsEmail() {
	if(window.plugins != undefined && window.plugins.emailComposer != undefined && window.plugins.emailComposer.showEmailComposerWithCallback != undefined && asciiArtTextString != undefined){
		var ret = window.plugins.emailComposer.showEmailComposerWithCallback(
			function(result){
				console.log('email sent with result ' + result);
			},
			"ASCII Art",
			asciiArtTextString,[],[],[],false,[]);			
		console.log('email returned ' + ret);
	}
}
