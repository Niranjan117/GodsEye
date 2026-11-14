import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart' hide FluentIcons;
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/widgets.dart' as widgets;

void main() {
  runApp(const GodsEyeApp());
}

class GodsEyeApp extends StatelessWidget {
  const GodsEyeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: "God's Eye",
      debugShowCheckedModeBanner: false,
      theme: FluentThemeData(accentColor: Colors.blue, fontFamily: 'Segoe UI'),
      home: const AdminLoginScreen(),
    );
  }
}

class AdminLoginScreen extends StatelessWidget {
  const AdminLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      content: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  FluentIcons.shield_lock_24_regular,
                  size: 36,
                  color: Color(0xFF0067C0),
                ),
                const SizedBox(height: 14),
                const Text(
                  "God's Eye",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Administrator sign in',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 24),
                const Text('User name'),
                const SizedBox(height: 6),
                const TextBox(placeholder: 'Enter user name'),
                const SizedBox(height: 16),
                const Text('Password'),
                const SizedBox(height: 6),
                const PasswordBox(placeholder: 'Enter password'),
                const SizedBox(height: 22),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      FluentPageRoute<void>(builder: (_) => const MainWindow()),
                    );
                  },
                  child: const Text('Sign in'),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Preview only. Sign-in is not connected to an account.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _SearchMode { textDescription, targetTrackMatch }

class _SearchMatch {
  const _SearchMatch({
    required this.trackId,
    required this.camera,
    required this.timestamp,
    required this.score,
    required this.clothing,
    required this.gait,
    required this.face,
    required this.fusionMode,
  });

  final String trackId;
  final String camera;
  final String timestamp;
  final double score;
  final double clothing;
  final double gait;
  final double? face;
  final String fusionMode;
}

class _Sighting {
  const _Sighting({
    required this.camera,
    required this.timestamp,
    required this.score,
    required this.clothing,
    required this.gait,
    required this.face,
  });

  final String camera;
  final String timestamp;
  final double score;
  final double clothing;
  final double gait;
  final double? face;
}

class _LocalController extends ChangeNotifier {
  static const feeds = ['North Gate', 'Lobby'];
  static const trackIds = [
    'Track_01',
    'Track_02',
    'Track_03',
    'Track_04',
    'Track_05',
    'Track_06',
    'Track_07',
    'Track_08',
  ];

  final queryController = widgets.TextEditingController();
  final Map<String, String> settings = {
    'Preview quality': 'Standard',
    'Workspace layout': 'Classic',
    'Gait frame sampling': '60 Frames (Full Window)',
    'Matching weight mode': 'Auto-Adaptive (Default)',
    'Face confidence threshold': '65% (Recommended)',
    'Minimum tracklet length': '30 Frames (Balanced)',
    'Maximum results (Top-K)': 'Top 10',
    'Auto-clear detection log': 'Enabled',
  };

  String activeFeed = feeds.first;
  String? loadedFeed;
  String? loadedFileName;
  bool isLoading = false;
  String? errorMessage;
  _SearchMode searchMode = _SearchMode.textDescription;
  String query = '';
  String targetTrackId = trackIds.first;
  bool clothesChangedMode = false;
  String selectedTrackId = trackIds.first;
  List<_SearchMatch>? results;

  bool get isCompact => settings['Workspace layout'] == 'Compact';

  @override
  void dispose() {
    queryController.dispose();
    super.dispose();
  }

  void selectFeed(String feed) {
    if (!feeds.contains(feed)) return;
    activeFeed = feed;
    notifyListeners();
  }

  void setSetting(String name, String value) {
    settings[name] = value;
    notifyListeners();
  }

  void setLayoutFromBar(String? value) {
    if (value == null) return;
    setSetting('Workspace layout', value == 'Compact' ? 'Compact' : 'Classic');
  }

  void setSearchMode(_SearchMode mode) {
    searchMode = mode;
    errorMessage = null;
    notifyListeners();
  }

  void setQuery(String value) {
    query = value;
    errorMessage = null;
  }

  void setTargetTrack(String? value) {
    if (value == null || !trackIds.contains(value)) return;
    targetTrackId = value;
    notifyListeners();
  }

  void setClothesChanged(bool? value) {
    if (value == null) return;
    clothesChangedMode = value;
    notifyListeners();
  }

  void selectTrack(String trackId) {
    if (!trackIds.contains(trackId)) return;
    selectedTrackId = trackId;
    notifyListeners();
  }

  Future<void> loadFeed() async {
    errorMessage = null;
    isLoading = true;
    notifyListeners();
    try {
      final selection = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['mp4', 'avi', 'mkv'],
        dialogTitle: 'Load camera feed',
      );
      final path = selection?.files.single.path;
      if (path == null) return;
      final fileName = path.split(RegExp(r'[/\\]')).last;
      loadedFeed = activeFeed;
      loadedFileName = fileName;
      if (settings['Auto-clear detection log'] == 'Enabled') {
        results = null;
        selectedTrackId = trackIds.first;
      }
      await Future<void>.delayed(const Duration(milliseconds: 350));
    } catch (error) {
      errorMessage = 'Unable to load the selected feed: $error';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearResults() {
    results = null;
    errorMessage = null;
    notifyListeners();
  }

  void search() {
    errorMessage = null;
    if (searchMode == _SearchMode.textDescription && query.trim().isEmpty) {
      errorMessage = 'Enter a description before searching.';
      notifyListeners();
      return;
    }

    final threshold = _faceThreshold;
    final minimumFrames = int.parse(
      settings['Minimum tracklet length']!.replaceAll(RegExp(r'[^0-9]'), ''),
    );
    const trackletFrames = [48, 42, 27, 64, 18, 55, 33, 72];
    final queryNudge = searchMode == _SearchMode.textDescription
        ? (query.trim().length % 5) * 0.004
        : 0.0;
    final matches = <_SearchMatch>[];
    for (var index = 0; index < trackIds.length; index++) {
      if (trackletFrames[index] < minimumFrames) continue;
      final trackId = trackIds[index];
      final clothing = (0.91 - index * 0.037).clamp(0.52, 0.95).toDouble();
      var gait = (0.83 + (index % 3) * 0.035).clamp(0.5, 0.95).toDouble();
      if (settings['Gait frame sampling'] == '30 Frames (Fast - 1.93x)') {
        gait = (gait * 0.97).clamp(0.0, 1.0).toDouble();
      }
      final visibleFace = [
        0.78,
        0.48,
        0.72,
        0.61,
        0.84,
        0.53,
        0.75,
        0.67,
      ][index];
      final face = visibleFace >= threshold ? visibleFace : null;
      final mode = _fusionModeFor(face);
      var score = _combinedScore(mode, clothing, gait, face);
      if (searchMode == _SearchMode.targetTrackMatch &&
          trackId == targetTrackId) {
        score += 0.06;
      }
      score = (score + queryNudge).clamp(0.0, 0.999).toDouble();
      matches.add(
        _SearchMatch(
          trackId: trackId,
          camera: index.isEven ? activeFeed : _otherFeed(activeFeed),
          timestamp:
              '10:${14 + index ~/ 4}:${((8 + index * 7) % 60).toString().padLeft(2, '0')}',
          score: score,
          clothing: clothing,
          gait: gait,
          face: face,
          fusionMode: mode,
        ),
      );
    }
    matches.sort((a, b) => b.score.compareTo(a.score));
    if (searchMode == _SearchMode.targetTrackMatch) {
      matches.sort((a, b) {
        if (a.trackId == targetTrackId) return -1;
        if (b.trackId == targetTrackId) return 1;
        return b.score.compareTo(a.score);
      });
    }
    final limit = int.parse(
      settings['Maximum results (Top-K)']!.replaceAll(RegExp(r'[^0-9]'), ''),
    );
    results = matches.take(limit).toList();
    selectedTrackId = results!.first.trackId;
    notifyListeners();
  }

  String _fusionModeFor(double? face) {
    final configured = settings['Matching weight mode']!;
    if (clothesChangedMode ||
        configured == 'Clothes Changed (15% Look / 85% Gait)') {
      return 'Gait Lock 15/85';
    }
    if (face == null) return 'Gait Lock 15/85';
    if (configured == 'Face Priority (60% Face / 25% Look / 15% Gait)') {
      return 'Face Priority 60/25/15';
    }
    return 'Standard 55/45';
  }

  double _combinedScore(
    String mode,
    double clothing,
    double gait,
    double? face,
  ) {
    return switch (mode) {
      'Gait Lock 15/85' => clothing * 0.15 + gait * 0.85,
      'Face Priority 60/25/15' =>
        clothing * 0.25 + gait * 0.15 + (face ?? 0) * 0.6,
      _ => clothing * 0.55 + gait * 0.45,
    };
  }

  double get _faceThreshold {
    final threshold = settings['Face confidence threshold']!;
    if (threshold.startsWith('50')) return 0.5;
    if (threshold.startsWith('80')) return 0.8;
    return 0.65;
  }

  _SearchMatch? get selectedMatch {
    final currentResults = results;
    if (currentResults == null) return null;
    for (final result in currentResults) {
      if (result.trackId == selectedTrackId) return result;
    }
    return null;
  }

  List<_Sighting> get selectedSightings {
    final selected = selectedMatch;
    final index = trackIds
        .indexOf(selectedTrackId)
        .clamp(0, trackIds.length - 1);
    final clothing = selected?.clothing ?? (0.88 - index * 0.025);
    final gait = selected?.gait ?? (0.86 + (index % 3) * 0.025);
    final face =
        selected?.face ??
        ([0.78, 0.48, 0.72, 0.61, 0.84, 0.53, 0.75, 0.67][index] >=
                _faceThreshold
            ? [0.78, 0.48, 0.72, 0.61, 0.84, 0.53, 0.75, 0.67][index]
            : null);
    final mode = selected?.fusionMode ?? _fusionModeFor(face);
    return [
      _Sighting(
        camera: feeds.first,
        timestamp: '10:14:08',
        score: (selected?.score ?? _combinedScore(mode, clothing, gait, face)),
        clothing: clothing,
        gait: gait,
        face: face,
      ),
      _Sighting(
        camera: feeds.last,
        timestamp: '10:21:36',
        score: _combinedScore(
          mode,
          (clothing - 0.03).clamp(0.0, 1.0).toDouble(),
          (gait + 0.02).clamp(0.0, 1.0).toDouble(),
          face == null ? null : (face - 0.04).clamp(0.0, 1.0).toDouble(),
        ).clamp(0.0, 1.0).toDouble(),
        clothing: (clothing - 0.03).clamp(0.0, 1.0),
        gait: (gait + 0.02).clamp(0.0, 1.0),
        face: face == null ? null : (face - 0.04).clamp(0.0, 1.0),
      ),
    ];
  }

  String _otherFeed(String feed) =>
      feed == feeds.first ? feeds.last : feeds.first;
}

class MainWindow extends StatefulWidget {
  const MainWindow({super.key});

  @override
  State<MainWindow> createState() => _MainWindowState();
}

class _MainWindowState extends State<MainWindow> {
  final _controller = _LocalController();
  int _selectedTab = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => ScaffoldPage(
        padding: EdgeInsets.zero,
        content: Container(
          color: const Color(0xFFF3F3F3),
          child: TabView(
            currentIndex: _selectedTab,
            onChanged: (index) => setState(() => _selectedTab = index),
            closeButtonVisibility: CloseButtonVisibilityMode.never,
            tabs: [
              Tab(
                text: const Text('Find'),
                icon: const Icon(FluentIcons.search_24_regular),
                body: _FindTab(
                  controller: _controller,
                  onOpenTrack: () => setState(() => _selectedTab = 1),
                ),
              ),
              Tab(
                text: const Text('Track'),
                icon: const Icon(FluentIcons.video_24_regular),
                body: _TrackTab(controller: _controller),
              ),
              Tab(
                text: const Text('Settings'),
                icon: const Icon(FluentIcons.settings_24_regular),
                body: _SettingsPage(
                  controller: _controller,
                  onReturn: () => setState(() => _selectedTab = 0),
                ),
              ),
              Tab(
                text: const Text('Hints'),
                icon: const Icon(FluentIcons.question_circle_24_regular),
                body: const _HintsPage(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FindTab extends StatelessWidget {
  const _FindTab({required this.controller, required this.onOpenTrack});

  final _LocalController controller;
  final VoidCallback onOpenTrack;

  @override
  Widget build(BuildContext context) {
    final compact = controller.isCompact;
    return Padding(
      padding: EdgeInsets.all(compact ? 10 : 16),
      child: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final narrow = constraints.maxWidth < 900;
                final leftWidth = narrow ? 160.0 : 196.0;
                final rightWidth = narrow ? 225.0 : 252.0;
                final gap = compact ? 8.0 : 14.0;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: leftWidth,
                      child: _FeedList(controller: controller),
                    ),
                    SizedBox(width: gap),
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            flex: 3,
                            child: _ContentPanel(
                              title: 'Camera feed',
                              icon: FluentIcons.camera_24_regular,
                              child: _FeedPreview(controller: controller),
                            ),
                          ),
                          SizedBox(height: gap),
                          Expanded(
                            flex: 2,
                            child: _ContentPanel(
                              title: 'Detection log and results',
                              icon: FluentIcons.document_24_regular,
                              child: _ResultsList(
                                controller: controller,
                                onOpenTrack: onOpenTrack,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: gap),
                    SizedBox(
                      width: rightWidth,
                      child: _ActionPanel(controller: controller),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          _BottomBar(controller: controller, feedLabel: 'Find feed'),
        ],
      ),
    );
  }
}

class _FeedList extends StatelessWidget {
  const _FeedList({required this.controller});

  final _LocalController controller;

  @override
  Widget build(BuildContext context) {
    return _ContentPanel(
      title: 'Find feeds',
      icon: FluentIcons.folder_24_regular,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 6),
        children: _LocalController.feeds.map((feed) {
          final selected = controller.activeFeed == feed;
          final loaded = controller.loadedFeed == feed;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            child: Button(
              onPressed: () => controller.selectFeed(feed),
              style: ButtonStyle(
                padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2),
                    side: BorderSide(
                      color: selected
                          ? const Color(0xFF0067C0)
                          : const Color(0xFFD9D9D9),
                    ),
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Icon(FluentIcons.camera_20_regular, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(feed, overflow: TextOverflow.ellipsis)),
                  Text(
                    loaded ? 'Loaded' : 'Idle',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: loaded
                          ? const Color(0xFF107C10)
                          : const Color(0xFF8A8886),
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(color: const Color(0xFF0067C0), width: 1)
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ContentPanel extends StatelessWidget {
  const _ContentPanel({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final widgets.IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFD6D6D6))),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: const Color(0xFF0067C0)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _FeedPreview extends StatelessWidget {
  const _FeedPreview({required this.controller});

  final _LocalController controller;

  @override
  Widget build(BuildContext context) {
    final loaded =
        controller.loadedFeed == controller.activeFeed &&
        controller.loadedFileName != null;
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            color: const Color(0xFF17191C),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  loaded
                      ? FluentIcons.video_clip_24_regular
                      : FluentIcons.video_24_regular,
                  size: 34,
                  color: const Color(0xB3FFFFFF),
                ),
                const SizedBox(height: 10),
                Text(
                  loaded ? controller.loadedFileName! : 'No camera feed loaded',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  loaded
                      ? '${controller.activeFeed}  •  '
                            '${controller.settings['Preview quality']} quality'
                      : '${controller.activeFeed}  •  Select Load Feed to open a video',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFBBBBBB),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (controller.isLoading)
          const Positioned(left: 0, right: 0, top: 0, child: ProgressBar()),
        if (loaded)
          Positioned(
            left: 8,
            right: 8,
            bottom: 8,
            child: SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _LocalController.trackIds.take(3).map((id) {
                  final selected = controller.selectedTrackId == id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Button(
                      onPressed: () => controller.selectTrack(id),
                      child: Row(
                        children: [
                          const Icon(
                            FluentIcons.person_24_regular,
                            size: 17,
                            color: Color(0xFF0067C0),
                          ),
                          const SizedBox(width: 5),
                          Text(id),
                          if (selected) ...[
                            const SizedBox(width: 5),
                            const Icon(
                              FluentIcons.checkmark_16_regular,
                              size: 14,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }
}

class _ResultsList extends StatelessWidget {
  const _ResultsList({required this.controller, required this.onOpenTrack});

  final _LocalController controller;
  final VoidCallback onOpenTrack;

  @override
  Widget build(BuildContext context) {
    final results = controller.results;
    if (results == null || results.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('No results to display.', style: TextStyle(fontSize: 13)),
              SizedBox(height: 6),
              Text(
                'Run a search to see ranked local matches.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: results.length,
      separatorBuilder: (_, _) => const Divider(),
      itemBuilder: (context, index) {
        final match = results[index];
        final selected = controller.selectedTrackId == match.trackId;
        return Button(
          onPressed: () {
            controller.selectTrack(match.trackId);
            onOpenTrack();
          },
          style: ButtonStyle(
            padding: const WidgetStatePropertyAll(EdgeInsets.all(8)),
            backgroundColor: WidgetStatePropertyAll(
              selected ? const Color(0xFFEAF2F8) : Colors.transparent,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '#${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EEF4),
                  border: Border.all(color: const Color(0xFFD9D9D9)),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: const Icon(
                  FluentIcons.person_24_regular,
                  color: Color(0xFF0067C0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${match.trackId}  •  ${match.camera}  •  ${match.timestamp}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${(match.score * 100).toStringAsFixed(1)}% Match',
                      style: const TextStyle(
                        color: Color(0xFF0067C0),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Clothing: ${match.clothing.toStringAsFixed(2)} | '
                      'Gait: ${match.gait.toStringAsFixed(2)} | '
                      'Face: ${match.face?.toStringAsFixed(2) ?? 'None'}  •  '
                      '${match.fusionMode}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActionPanel extends StatelessWidget {
  const _ActionPanel({required this.controller});

  final _LocalController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Commands', style: FluentTheme.of(context).typography.subtitle),
        const SizedBox(height: 10),
        _CommandButton(
          label: 'Load Feed',
          icon: FluentIcons.folder_open_24_regular,
          onPressed: controller.loadFeed,
        ),
        const SizedBox(height: 8),
        _CommandButton(
          label: 'Search',
          icon: FluentIcons.search_24_regular,
          primary: true,
          onPressed: controller.search,
        ),
        const SizedBox(height: 8),
        _CommandButton(
          label: 'Clear Results',
          icon: FluentIcons.delete_24_regular,
          onPressed: controller.clearResults,
        ),
        const SizedBox(height: 10),
        Expanded(child: _SearchParameters(controller: controller)),
        if (controller.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              controller.errorMessage!,
              style: const TextStyle(fontSize: 11, color: Color(0xFFC42B1C)),
            ),
          ),
      ],
    );
  }
}

class _SearchParameters extends StatelessWidget {
  const _SearchParameters({required this.controller});

  final _LocalController controller;

  @override
  Widget build(BuildContext context) {
    return _ContentPanel(
      title: 'Search Parameters',
      icon: FluentIcons.filter_24_regular,
      child: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          const Text(
            'Search Mode',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 5),
          _Dropdown(
            value: controller.searchMode == _SearchMode.textDescription
                ? 'Text Description'
                : 'Target Track Match',
            options: const ['Text Description', 'Target Track Match'],
            onChanged: (value) => controller.setSearchMode(
              value == 'Target Track Match'
                  ? _SearchMode.targetTrackMatch
                  : _SearchMode.textDescription,
            ),
          ),
          const SizedBox(height: 12),
          if (controller.searchMode == _SearchMode.textDescription) ...[
            const Text(
              'Text Query',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 5),
            TextBox(
              controller: controller.queryController,
              placeholder: 'e.g., blue jeans, black backpack',
              onChanged: controller.setQuery,
            ),
          ] else ...[
            const Text(
              'Target Track ID',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 5),
            _Dropdown(
              value: controller.targetTrackId,
              options: _LocalController.trackIds,
              onChanged: controller.setTargetTrack,
            ),
          ],
          const SizedBox(height: 12),
          Checkbox(
            checked: controller.clothesChangedMode,
            onChanged: controller.setClothesChanged,
            content: const SizedBox(
              width: 158,
              child: Text(
                'Clothes Changed (85% Gait Lock)',
                maxLines: 2,
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommandButton extends StatelessWidget {
  const _CommandButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.primary = false,
  });

  final String label;
  final widgets.IconData icon;
  final VoidCallback onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(label)),
      ],
    );
    return SizedBox(
      height: 38,
      child: primary
          ? FilledButton(onPressed: onPressed, child: child)
          : Button(onPressed: onPressed, child: child),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.controller, required this.feedLabel});

  final _LocalController controller;
  final String feedLabel;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 900;
        final feedDropdown = _Dropdown(
          value: controller.activeFeed,
          options: _LocalController.feeds,
          onChanged: (value) {
            if (value != null) controller.selectFeed(value);
          },
        );
        final layoutDropdown = _Dropdown(
          value: controller.isCompact ? 'Compact' : 'Default',
          options: const ['Default', 'Compact'],
          onChanged: controller.setLayoutFromBar,
        );
        return Card(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: compact
              ? Column(
                  children: [
                    Row(
                      children: [
                        Text(feedLabel),
                        const SizedBox(width: 8),
                        Expanded(child: feedDropdown),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Layout'),
                        const SizedBox(width: 8),
                        Expanded(child: layoutDropdown),
                      ],
                    ),
                  ],
                )
              : Row(
                  children: [
                    Text(feedLabel),
                    const SizedBox(width: 8),
                    SizedBox(width: 210, child: feedDropdown),
                    const SizedBox(width: 20),
                    const Text('Layout'),
                    const SizedBox(width: 8),
                    SizedBox(width: 150, child: layoutDropdown),
                  ],
                ),
        );
      },
    );
  }
}

class _Dropdown extends StatelessWidget {
  const _Dropdown({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return ComboBox<String>(
      value: value,
      isExpanded: true,
      placeholder: const Text('Select...'),
      items: options
          .map(
            (option) =>
                ComboBoxItem<String>(value: option, child: Text(option)),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _TrackTab extends StatelessWidget {
  const _TrackTab({required this.controller});

  final _LocalController controller;

  @override
  Widget build(BuildContext context) {
    final match = controller.selectedMatch;
    final faceClear =
        match?.face != null ||
        (match == null &&
            [0.78, 0.48, 0.72, 0.61, 0.84, 0.53, 0.75, 0.67][_LocalController
                    .trackIds
                    .indexOf(controller.selectedTrackId)] >=
                controller._faceThreshold);
    final source = match?.camera ?? controller.activeFeed;
    return Padding(
      padding: EdgeInsets.all(controller.isCompact ? 10 : 16),
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 290,
                  child: _ContentPanel(
                    title: 'Selected Target Profile',
                    icon: FluentIcons.person_24_regular,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Track feeds',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF666666),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: 64,
                            height: 72,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8EEF4),
                              border: Border.all(
                                color: const Color(0xFFD9D9D9),
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: const Icon(
                              FluentIcons.person_24_regular,
                              size: 34,
                              color: Color(0xFF0067C0),
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Track ID',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF666666),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(controller.selectedTrackId),
                          const SizedBox(height: 12),
                          const Text(
                            'Source camera',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF666666),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(source),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: faceClear
                                  ? const Color(0xFFEAF4EA)
                                  : const Color(0xFFFFF4CE),
                              border: Border.all(
                                color: faceClear
                                    ? const Color(0xFF9FD89F)
                                    : const Color(0xFFE6C35C),
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Text(
                              faceClear
                                  ? 'Face Clear (>65%)'
                                  : 'Face Hidden — Gait Lock Active',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Checkbox(
                            checked: controller.clothesChangedMode,
                            onChanged: controller.setClothesChanged,
                            content: const SizedBox(
                              width: 190,
                              child: Text(
                                'Clothes Changed Mode',
                                maxLines: 2,
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: controller.isCompact ? 8 : 14),
                Expanded(
                  child: _ContentPanel(
                    title: 'Cross-Camera Sighting Timeline',
                    icon: FluentIcons.history_24_regular,
                    child: _SightingTimeline(controller: controller),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _BottomBar(controller: controller, feedLabel: 'Track feed'),
        ],
      ),
    );
  }
}

class _SightingTimeline extends StatelessWidget {
  const _SightingTimeline({required this.controller});

  final _LocalController controller;

  @override
  Widget build(BuildContext context) {
    final sightings = controller.selectedSightings;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Text(
          'Track log',
          style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
        ),
        const SizedBox(height: 8),
        for (var index = 0; index < sightings.length; index++) ...[
          _SightingRow(sighting: sightings[index]),
          if (index < sightings.length - 1) const Divider(),
        ],
      ],
    );
  }
}

class _SightingRow extends StatelessWidget {
  const _SightingRow({required this.sighting});

  final _Sighting sighting;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFE8EEF4),
              border: Border.all(color: const Color(0xFFD9D9D9)),
              borderRadius: BorderRadius.circular(2),
            ),
            child: const Icon(
              FluentIcons.camera_20_regular,
              color: Color(0xFF0067C0),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${sighting.camera}  •  ${sighting.timestamp}'),
                const SizedBox(height: 3),
                Text(
                  '${(sighting.score * 100).toStringAsFixed(1)}% Match',
                  style: const TextStyle(
                    color: Color(0xFF0067C0),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Clothing: ${sighting.clothing.toStringAsFixed(2)} | '
                  'Gait: ${sighting.gait.toStringAsFixed(2)} | '
                  'Face: ${sighting.face?.toStringAsFixed(2) ?? 'None'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsPage extends StatelessWidget {
  const _SettingsPage({required this.controller, required this.onReturn});

  final _LocalController controller;
  final VoidCallback onReturn;

  static const _rows = [
    (
      'Preview quality',
      'Choose the display quality for the feed preview.',
      FluentIcons.video_24_regular,
      ['Standard', 'High'],
    ),
    (
      'Workspace layout',
      'Choose how panels are arranged.',
      FluentIcons.arrow_expand_24_regular,
      ['Classic', 'Compact'],
    ),
    (
      'Gait frame sampling',
      'Select frame count per tracklet to balance speed and precision.',
      FluentIcons.video_clip_24_regular,
      ['30 Frames (Fast - 1.93x)', '60 Frames (Full Window)'],
    ),
    (
      'Matching weight mode',
      'Choose how Face, Clothing, and Gait scores are prioritized.',
      FluentIcons.options_24_regular,
      [
        'Auto-Adaptive (Default)',
        'Standard CCTV (55% Look / 45% Gait)',
        'Clothes Changed (15% Look / 85% Gait)',
        'Face Priority (60% Face / 25% Look / 15% Gait)',
      ],
    ),
    (
      'Face confidence threshold',
      'Minimum visibility score required before triggering facial match.',
      FluentIcons.person_24_regular,
      ['65% (Recommended)', '50% (Lenient)', '80% (Strict)'],
    ),
    (
      'Minimum tracklet length',
      'Minimum continuous frames required to register a walking subject.',
      FluentIcons.timer_24_regular,
      ['20 Frames (Short Clips)', '30 Frames (Balanced)', '60 Frames (Strict)'],
    ),
    (
      'Maximum results (Top-K)',
      'Maximum number of ranked matches displayed in the detection log.',
      FluentIcons.list_24_regular,
      ['Top 5', 'Top 10', 'Top 20'],
    ),
    (
      'Auto-clear detection log',
      'Automatically clear previous search results when loading a new feed.',
      FluentIcons.delete_24_regular,
      ['Enabled', 'Disabled'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings', style: FluentTheme.of(context).typography.title),
          const SizedBox(height: 8),
          const Text('Configure feed preview and local matching behavior.'),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: [
                for (final row in _rows) ...[
                  _SettingRow(
                    icon: row.$3,
                    title: row.$1,
                    description: row.$2,
                    child: _Dropdown(
                      value: controller.settings[row.$1],
                      options: row.$4,
                      onChanged: (value) {
                        if (value != null) controller.setSetting(row.$1, value);
                      },
                    ),
                  ),
                  const Divider(),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Button(onPressed: onReturn, child: const Text('Return to console')),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    required this.description,
    required this.child,
  });

  final widgets.IconData icon;
  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 24, color: const Color(0xFF0067C0)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(width: 230, child: child),
        ],
      ),
    );
  }
}

class _HintsPage extends StatelessWidget {
  const _HintsPage();

  static const _hints = [
    (
      'Text Description Search',
      'Choose Text Description, enter visible details such as clothing or a bag, '
          'then run Search. Local sample matches are ranked to demonstrate the controls.',
      FluentIcons.search_24_regular,
    ),
    (
      'Target Track Match',
      'Choose an existing Track ID to rank that target first and compare its '
          'sightings across North Gate and Lobby.',
      FluentIcons.person_24_regular,
    ),
    (
      'Clothes Changed Mode (85% Gait)',
      'Enable this mode when clothing may have changed. The sample scoring '
          'switches to 15% appearance and 85% gait.',
      FluentIcons.person_24_regular,
    ),
    (
      'Similarity score weights',
      'Standard mode uses 55% clothing and 45% gait. Face Priority uses '
          '60% face, 25% clothing, and 15% gait when the face meets the configured '
          'visibility threshold.',
      FluentIcons.data_pie_24_regular,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hints', style: FluentTheme.of(context).typography.title),
          const SizedBox(height: 8),
          const Text('Getting started'),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                for (final hint in _hints) ...[
                  Card(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(hint.$3, size: 24, color: const Color(0xFF0067C0)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hint.$1,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                hint.$2,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF666666),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
