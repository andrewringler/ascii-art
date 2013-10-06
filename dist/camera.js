var newImageSrc;
var newImageLoaded;

var pictureSource;   // picture source
    var destinationType; // sets the format of returned value 

    // Wait for Cordova to connect with the device
    //
    document.addEventListener("deviceready",onDeviceReady,false);

    // Cordova is ready to be used!
    //
    function onDeviceReady() {
        pictureSource=navigator.camera.PictureSourceType;
        destinationType=navigator.camera.DestinationType;
    }

    // Called when a photo is successfully retrieved
    //
    function onPhotoDataSuccess(imageData) {
      // Uncomment to view the base64 encoded image data
      // console.log(imageData);

      // Get image handle
      //
      var smallImage = document.getElementById('smallImage');

      // Unhide image elements
      //
      smallImage.style.display = 'block';
  
      newImageSrc = "data:image/jpeg;base64," + imageData;
      smallImage.onload = function(){
        newImageLoaded = true;
      };
  
      // Show the captured photo
      // The inline CSS rules are used to resize the image
      //	  
      smallImage.src = newImageSrc;
    }
	
    // Called when a photo is successfully retrieved
    //
    function onPhotoDataSuccessFileURI(imageURI) {
      // Uncomment to view the base64 encoded image data
      // console.log(imageData);

      // Get image handle
      //
      var smallImage = document.getElementById('smallImage');
	  
      // Unhide image elements
      //
      smallImage.style.display = 'block';
	  
      newImageSrc = imageURI;
      smallImage.onload = function(){
        newImageLoaded = true;
      };

      // Show the captured photo
      // The inline CSS rules are used to resize the image
      //
      smallImage.src = imageURI;
    }

    // Called when a photo is successfully retrieved
    //
    function onPhotoURISuccess(imageURI) {
      // Uncomment to view the image file URI 
      // console.log(imageURI);

      // Get image handle
      //
      var largeImage = document.getElementById('largeImage');

      // Unhide image elements
      //
      largeImage.style.display = 'block';

      // Show the captured photo
      // The inline CSS rules are used to resize the image
      //
      largeImage.src = imageURI;
    }

    // A button will call this function
    //
    function capturePhoto() {
      // Take picture using device camera and retrieve image as base64-encoded string
      navigator.camera.getPicture(onPhotoDataSuccess, onFail, { quality: 75,
        destinationType: destinationType.DATA_URL,
        encodingType: Camera.EncodingType.JPEG,
        targetWidth: window.innerWidth,
        targetHeight: 500
      });
    }
	
    // A button will call this function
    //
    function capturePhotoFileURI() {
      // Take picture using device camera and retrieve image as file uri
      navigator.camera.getPicture(onPhotoDataSuccessFileURI, onFail, { quality: 40,
        destinationType: destinationType.FILE_URI });
    }

    // A button will call this function
    //
    function capturePhotoEdit() {
      // Take picture using device camera, allow edit, and retrieve image as base64-encoded string  
      navigator.camera.getPicture(onPhotoDataSuccess, onFail, { quality: 20, allowEdit: true,
        destinationType: destinationType.DATA_URL });
    }

    // A button will call this function
    //
    function getPhoto(source) {
      // Retrieve image file location from specified source
      navigator.camera.getPicture(onPhotoURISuccess, onFail, { quality: 50, 
        destinationType: destinationType.FILE_URI,
        sourceType: source });
    }

    // Called if something bad happens.
    // 
    function onFail(message) {
      alert('Failed because: ' + message);
    }
