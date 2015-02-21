$(document).on('ready', function () {
    $('html').on('click', '.watched', function (e) {
        var movieId = $(this).data('movie-id');
        $.ajax({
            type: 'POST',
            url: '/index/movie_watched_ajax',
            data: {
                movie_id: movieId
            }
        });
        $(this).closest('.movie-container').fadeTo(1, 0.3);
    })
});

var initShowMore = function() {
    $('a[name=show-more]').on('click', function (e) {
        var el = $(this).parent();
        el.hide();
        el.next().show();
    });
}