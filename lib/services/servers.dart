class StreamServers {
  static const Map<String, Map<String, dynamic>> servers = {
    'vixsrc': {
      'label': 'VixSrc',
      'movie': 'https://vixsrc.to/movie/{id}?autoplay=1',
      'tv': 'https://vixsrc.to/tv/{id}/{s}/{e}?autoplay=1',
    },
    'videasy': {
      'label': 'Videasy',
      'movie': 'https://player.videasy.net/movie/{id}?autoplay=true&nextButton=false',
      'tv': 'https://player.videasy.net/tv/{id}/{s}/{e}?autoplay=true&nextButton=false',
    },
    'vidlink': {
      'label': 'VidLink',
      'movie': 'https://vidlink.pro/movie/{id}?primaryColor=ece8e0&autoplay=true&next=1',
      'tv': 'https://vidlink.pro/tv/{id}/{s}/{e}?primaryColor=ece8e0&autoplay=true&next=1',
    },
    'vidsrc': {
      'label': 'VidSrc',
      'movie': 'https://vidsrc.xyz/embed/movie?tmdb={id}&autoplay=1',
      'tv': 'https://vidsrc.xyz/embed/tv?tmdb={id}&season={s}&episode={e}&autoplay=1',
    },
    'vidcore': {
      'label': 'VidCore',
      'movie': 'https://vidcore.org/embed/movie/{id}?autoplay=true&theme=ece8e0',
      'tv': 'https://vidcore.org/embed/tv/{id}/{s}/{e}?autoplay=true&theme=ece8e0',
    },
  };

  static const List<String> order = ['vixsrc', 'videasy', 'vidlink', 'vidsrc', 'vidcore'];

  static String urlFor(String serverKey, String mediaType, int id, {int season = 1, int episode = 1}) {
    final srv = servers[serverKey] ?? servers['vixsrc']!;
    final template = mediaType == 'tv' ? srv['tv'] as String : srv['movie'] as String;
    return template
        .replaceAll('{id}', id.toString())
        .replaceAll('{s}', season.toString())
        .replaceAll('{e}', episode.toString());
  }
}
