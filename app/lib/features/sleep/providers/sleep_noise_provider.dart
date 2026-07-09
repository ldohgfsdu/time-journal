import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

enum SleepNoiseId { rain, wave, fire, wind }

class SleepNoiseOption {
  const SleepNoiseOption({
    required this.id,
    required this.label,
    required this.assetPath,
  });

  final SleepNoiseId id;
  final String label;
  final String assetPath;
}

const sleepNoiseOptions = [
  SleepNoiseOption(
    id: SleepNoiseId.rain,
    label: '雨声',
    assetPath: 'assets/audio/rain.mp3',
  ),
  SleepNoiseOption(
    id: SleepNoiseId.wave,
    label: '海浪',
    assetPath: 'assets/audio/wave.mp3',
  ),
  SleepNoiseOption(
    id: SleepNoiseId.fire,
    label: '篝火',
    assetPath: 'assets/audio/fire.mp3',
  ),
  SleepNoiseOption(
    id: SleepNoiseId.wind,
    label: '风声',
    assetPath: 'assets/audio/wind.mp3',
  ),
];

class SleepNoiseState {
  const SleepNoiseState({
    this.selected,
    this.playing = false,
    this.volume = 0.6,
    this.loading = false,
    this.error,
  });

  final SleepNoiseId? selected;
  final bool playing;
  final double volume;
  final bool loading;
  final String? error;

  SleepNoiseState copyWith({
    SleepNoiseId? selected,
    bool? playing,
    double? volume,
    bool? loading,
    String? error,
    bool clearSelected = false,
    bool clearError = false,
  }) {
    return SleepNoiseState(
      selected: clearSelected ? null : (selected ?? this.selected),
      playing: playing ?? this.playing,
      volume: volume ?? this.volume,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class SleepNoiseController extends StateNotifier<SleepNoiseState> {
  SleepNoiseController({AudioPlayer? player})
    : _player = player ?? AudioPlayer(),
      super(const SleepNoiseState()) {
    unawaited(_player.setLoopMode(LoopMode.one));
    unawaited(_player.setVolume(state.volume));
  }

  final AudioPlayer _player;
  int _requestId = 0;

  Future<void> select(SleepNoiseId id) async {
    if (state.selected == id && state.playing) {
      await stop();
      return;
    }
    final requestId = ++_requestId;
    final option = sleepNoiseOptions.firstWhere((opt) => opt.id == id);
    state = state.copyWith(
      selected: id,
      playing: false,
      loading: true,
      clearError: true,
    );
    try {
      await _player.stop();
      await _player.setAsset(option.assetPath);
      await _player.setLoopMode(LoopMode.one);
      await _player.setVolume(state.volume);
      await _player.play();
      if (requestId == _requestId) {
        state = state.copyWith(playing: true, loading: false);
      }
    } catch (_) {
      if (requestId == _requestId) {
        state = state.copyWith(
          playing: false,
          loading: false,
          error: '声音加载失败，请稍后再试',
        );
      }
    }
  }

  Future<void> stop() async {
    _requestId++;
    await _player.stop();
    state = state.copyWith(playing: false, loading: false, clearError: true);
  }

  Future<void> setVolume(double value) async {
    final volume = value.clamp(0.0, 1.0);
    state = state.copyWith(volume: volume);
    await _player.setVolume(volume);
  }

  @override
  void dispose() {
    unawaited(_player.dispose());
    super.dispose();
  }
}

final sleepNoiseProvider =
    StateNotifierProvider<SleepNoiseController, SleepNoiseState>((ref) {
      return SleepNoiseController();
    });
