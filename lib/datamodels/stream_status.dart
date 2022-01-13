class StreamStatus {
  final bool twitchLive;
  final bool youtubeLive;
  final String? youtubeId;

  const StreamStatus({
    required this.twitchLive,
    required this.youtubeLive,
    this.youtubeId,
  });
}
