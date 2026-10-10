class ReelItem {
  final int id;
  final String mediaType; // 'movie' or 'tv'
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final String? trailerKey;
  final double voteAverage;
  final int? releaseYear;
  final List<String> genres;

  ReelItem({
    required this.id,
    required this.mediaType,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    this.trailerKey,
    this.voteAverage = 0,
    this.releaseYear,
    this.genres = const [],
  });

  String get posterUrl => posterPath != null
      ? 'https://image.tmdb.org/t/p/w500$posterPath'
      : '';
  String get backdropUrl => backdropPath != null
      ? 'https://image.tmdb.org/t/p/w1280$backdropPath'
      : posterUrl;

  factory ReelItem.fromJson(Map<String, dynamic> json, {String? type}) {
    final mt = type ?? (json['media_type'] == 'tv' ? 'tv' : 'movie');
    final date = json['release_date'] ?? json['first_air_date'] ?? '';
    return ReelItem(
      id: json['id'] as int,
      mediaType: mt,
      title: (json['title'] ?? json['name'] ?? 'Untitled') as String,
      overview: (json['overview'] ?? '') as String,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
      releaseYear: date.isNotEmpty ? int.tryParse(date.substring(0, 4)) : null,
      genres: (json['genre_ids'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
