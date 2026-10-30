import 'dart:io';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class VideoSurface extends StatefulWidget {
  const VideoSurface({
    super.key,
    required this.asset,
    this.poster,
    this.fit = BoxFit.cover,
    this.autoPlay = true,
    this.loop = true,
  });

  final String asset;
  final String? poster;
  final BoxFit fit;
  final bool autoPlay;
  final bool loop;

  @override
  State<VideoSurface> createState() => _VideoSurfaceState();
}

class _VideoSurfaceState extends State<VideoSurface> {
  Player? _player;
  VideoController? _controller;
  bool _ready = false;

  bool get _isTest => Platform.environment.containsKey('FLUTTER_TEST');

  @override
  void initState() {
    super.initState();
    if (_isTest) return;
    _player = Player();
    _controller = VideoController(_player!);
    _open();
  }

  Future<void> _open() async {
    final player = _player;
    if (player == null) return;
    await player.setVolume(0);
    await player.setPlaylistMode(
      widget.loop ? PlaylistMode.loop : PlaylistMode.none,
    );
    await player.open(Media('asset:///${widget.asset}'), play: false);
    if (!mounted) return;
    setState(() => _ready = true);
    if (widget.autoPlay) await player.play();
  }

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isTest) {
      if (widget.poster != null) {
        return Image.asset(widget.poster!, fit: widget.fit);
      }
      return const SizedBox.shrink();
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        if (widget.poster != null)
          Image.asset(widget.poster!, fit: widget.fit),
        if (_ready && _controller != null)
          Video(
            controller: _controller!,
            fit: widget.fit,
            controls: NoVideoControls,
          ),
      ],
    );
  }
}
