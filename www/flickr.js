function flickrRequest() {  
  var flickerAPI = "http://api.flickr.com/services/feeds/photos_public.gne?jsoncallback=?";
  $.getJSON(flickerAPI, {
    tags: "person, happy",
    tagmode: "any",
    format: "json"
  })
    .done(function( data ) {
      $.each( data.items, function( i, item ) {
        console.log(item.media.m);
        if ( i === 3 ) {
          return false;
        }
      });
    });
};

function jsonFlickrApi(cb) {
    var flickerAPI = "http://api.flickr.com/services/rest/?jsoncallback=?";
    $.getJSON(flickerAPI, {
      api_key: "66c61b93c4723c7c3a3c519728eac252",
      method: "flickr.photos.search",
      sort: "interestingness-desc",
      tags: "person, happy",
      tagmode: "any",
      format: "json",
      per_page: "10",
      content_type: "1",
      media: "photos",
      in_gallery: "true"
    }).done(function( data ) {
       var s = "";
       var i = Math.random();
       i = i * data.photos.photo.length;
       i = Math.ceil(i);
       
       photo = data.photos.photo[i];
       
       if(photo){
         // http://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}_[mstzb].jpg
         t_url = "http://farm" + photo.farm +
         ".static.flickr.com/" + photo.server + "/" +         
         photo.id + "_" + photo.secret + "_" + "z.jpg";
         
         p_url = "http://www.flickr.com/photos/" +
         photo.owner + "/" + photo.id;
         
         //console.log(photo.title + " " + t_url + " " + p_url);
         //s =  '<img alt="'+ photo.title + '"src="' + t_url + '"/>'  ;
         
         cb({
           src: t_url,
           path: p_url,
           title: photo.title
         });
       }
   });
}
