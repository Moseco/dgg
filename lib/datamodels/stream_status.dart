class StreamStatus {
  final bool twitchLive;
  final bool youtubeLive;
  final String? youtubeId;
  final bool rumbleLive;
  final String? rumbleId;
  final bool kickLive;
  final String? kickId;

  const StreamStatus({
    required this.twitchLive,
    required this.youtubeLive,
    this.youtubeId,
    required this.rumbleLive,
    this.rumbleId,
    required this.kickLive,
    this.kickId,
  });
}
