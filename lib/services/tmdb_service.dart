import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/reel_item.dart';

class TmdbService {
  static const String _base = 'https://api.themoviedb.org/3';
  static const String _key = '129637a8869a61522af21b80f6eb5129';

  static Future<List<ReelItem>> fetchLane(String lane, {int page = 1}) async {
    String path;
    Map<String, String> params = {
      'api_key': _key,
      'language': 'en-US',
      'page': page.toString(),
      'include_adult': 'false',
    };

    switch (lane) {
      case 'popular':
        path = '/trending/movie/week';
        break;
      case 'movies':
        path = '/discover/movie';
        params['sort_by'] = 'popularity.desc';
        params['with_original_language'] = 'en';
        break;
      case 'shows':
        path = '/discover/tv';
        params['sort_by'] = 'popularity.desc';
        break;
      case 'cartoons':
        path = '/discover/movie';
        params['with_genres'] = '16';
        params['sort_by'] = 'popularity.desc';
        break;
      case 'anime':
        path = '/discover/tv';
        params['with_genres'] = '16';
        params['with_original_language'] = 'ja';
        params['sort_by'] = 'popularity.desc';
        break;
      case 'kdrama':
        path = '/discover/tv';
        params['with_original_language'] = 'ko';
        params['sort_by'] = 'popularity.desc';
        break;
      case 'foryou':
      default:
        path = '/trending/all/day';
        break;
    }

    final uri = Uri.parse('$_base$path').replace(queryParameters: params);
    final res = await http.get(uri);
    if (res.statusCode != 200) throw Exception('TMDB error ${res.statusCode}');
    final data = jsonDecode(res.body);
    final results = (data['results'] as List).cast<Map<String, dynamic>>();
    final items = results.map((e) => ReelItem.fromJson(e)).toList();

    // Hydrate trailers for first few
    for (var i = 0; i < items.length && i < 8; i++) {
      items[i] = await _withTrailer(items[i]);
    }
    return items;
  }

  static Future<ReelItem> _withTrailer(ReelItem item) async {
    final path = item.mediaType == 'tv' ? '/tv/${item.id}/videos' : '/movie/${item.id}/videos';
    final uri = Uri.parse('$_base$path').replace(queryParameters: {
      'api_key': _key,
      'language': 'en-US',
    });
    try {
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final videos = (data['results'] as List).cast<Map<String, dynamic>>();
        final key = _pickTrailer(videos);
        return ReelItem(
          id: item.id,
          mediaType: item.mediaType,
          title: item.title,
          overview: item.overview,
          posterPath: item.posterPath,
          backdropPath: item.backdropPath,
          trailerKey: key,
          voteAverage: item.voteAverage,
          releaseYear: item.releaseYear,
          genres: item.genres,
        );
      }
    } catch (_) {}
    return item;
  }

  static String? _pickTrailer(List<Map<String, dynamic>> videos) {
    final yt = videos.where((v) => v['site'] == 'YouTube' && v['key'] != null).toList();
    if (yt.isEmpty) return null;
    yt.sort((a, b) {
      int rank(String? t) {
        final x = (t ?? '').toLowerCase();
        if (x == 'trailer') return 0;
        if (x == 'teaser') return 1;
        if (x.contains('trailer')) return 2;
        return 4;
      }
      final oa = (a['official'] == true || (a['name'] ?? '').toString().toLowerCase().contains('official')) ? 0 : 1;
      final ob = (b['official'] == true || (b['name'] ?? '').toString().toLowerCase().contains('official')) ? 0 : 1;
      return oa.compareTo(ob) != 0 ? oa.compareTo(ob) : rank(a['type']).compareTo(rank(b['type']));
    });
    return yt.first['key'] as String?;
  }
}
