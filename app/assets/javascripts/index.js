$(document).on('ready', function() {
   $('.watched').on('click', function(e) {
       var movieId = $(this).data('movie-id');
       $.ajax({
           type:'POST',
           url: '/index/movie_watched_ajax',
           data: {
               movie_id: movieId
           }
       });
       $(this).closest('.movie-container').fadeTo(1, 0.3);
   })
});