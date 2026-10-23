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

class MainWindow extends StatefulWidget {
  const MainWindow({super.key});

  @override
  State<MainWindow> createState() => _MainWindowState();
}

class _MainWindowState extends State<MainWindow> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      padding: EdgeInsets.zero,
      content: TabView(
        currentIndex: _selectedTab,
        onChanged: (index) => setState(() => _selectedTab = index),
        closeButtonVisibility: CloseButtonVisibilityMode.never,
        tabs: [
          Tab(
            text: const Text('Find'),
            icon: const Icon(FluentIcons.search_24_regular),
            body: _ConsoleTab(
              section: 'Find',
              icon: FluentIcons.search_24_regular,
              actionLabel: 'Search',
              feedLabel: 'Find feed',
              feedOptions: const ['Select a feed...', 'North Gate', 'Lobby'],
              onOptions: () => setState(() => _selectedTab = 2),
            ),
          ),
          Tab(
            text: const Text('Track'),
            icon: const Icon(FluentIcons.video_24_regular),
            body: _ConsoleTab(
              section: 'Track',
              icon: FluentIcons.video_24_regular,
              actionLabel: 'Track',
              feedLabel: 'Track feed',
              feedOptions: const ['Select a feed...', 'Camera 1', 'Camera 2'],
              onOptions: () => setState(() => _selectedTab = 2),
            ),
          ),
          Tab(
            text: const Text('Settings'),
            icon: const Icon(FluentIcons.settings_24_regular),
            body: _SettingsPage(
              onOptions: () => setState(() => _selectedTab = 0),
            ),
          ),
          Tab(
            text: const Text('Hints'),
            icon: const Icon(FluentIcons.question_circle_24_regular),
            body: const _HintsPage(),
          ),
        ],
      ),
    );
  }
}

class _ConsoleTab extends StatefulWidget {
  const _ConsoleTab({
    required this.section,
    required this.icon,
    required this.actionLabel,
    required this.feedLabel,
    required this.feedOptions,
    required this.onOptions,
  });

  final String section;
  final widgets.IconData icon;
  final String actionLabel;
  final String feedLabel;
  final List<String> feedOptions;
  final VoidCallback onOptions;

  @override
  State<_ConsoleTab> createState() => _ConsoleTabState();
}

class _ConsoleTabState extends State<_ConsoleTab> {
  String? _selectedFeed;
  String? _selectedLayout = 'Default';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 196,
                  child: _FeedList(
                    section: widget.section,
                    options: widget.feedOptions,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _ContentPanel(
                          title: 'Camera feed',
                          icon: FluentIcons.camera_24_regular,
                          child: const _FeedPreview(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        flex: 2,
                        child: _ContentPanel(
                          title: widget.section == 'Find'
                              ? 'Detection log and results'
                              : 'Track log',
                          icon: FluentIcons.document_24_regular,
                          child: const _ResultsList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                SizedBox(
                  width: 166,
                  child: _ActionPanel(
                    actionLabel: widget.actionLabel,
                    section: widget.section,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _BottomBar(
            feedLabel: widget.feedLabel,
            feedOptions: widget.feedOptions,
            selectedFeed: _selectedFeed,
            onFeedChanged: (value) => setState(() => _selectedFeed = value),
            selectedLayout: _selectedLayout,
            onLayoutChanged: (value) => setState(() => _selectedLayout = value),
            onOptions: widget.onOptions,
          ),
        ],
      ),
    );
  }
}

class _FeedList extends StatelessWidget {
  const _FeedList({required this.section, required this.options});

  final String section;
  final List<String> options;

  @override
  Widget build(BuildContext context) {
    return _ContentPanel(
      title: '$section feeds',
      icon: FluentIcons.folder_24_regular,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 6),
        children: options.skip(1).map((name) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            child: Button(
              onPressed: () {},
              style: ButtonStyle(
                padding: WidgetStatePropertyAll(
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
              ),
              child: Row(
                children: [
                  const Icon(FluentIcons.camera_20_regular, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(name, overflow: TextOverflow.ellipsis)),
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
  const _FeedPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF17191C),
      alignment: Alignment.center,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            FluentIcons.video_24_regular,
            size: 34,
            color: Color(0xB3FFFFFF),
          ),
          SizedBox(height: 10),
          Text(
            'No camera feed loaded',
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
          SizedBox(height: 4),
          Text(
            'Select a feed to preview',
            style: TextStyle(color: Color(0xFFBBBBBB), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ResultsList extends StatelessWidget {
  const _ResultsList();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: const [
        Text('No results to display.', style: TextStyle(fontSize: 13)),
        SizedBox(height: 6),
        Text(
          'Detection and matching are not enabled in this UI preview.',
          style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
        ),
      ],
    );
  }
}

class _ActionPanel extends StatelessWidget {
  const _ActionPanel({required this.actionLabel, required this.section});

  final String actionLabel;
  final String section;

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
          onPressed: () {},
        ),
        const SizedBox(height: 8),
        _CommandButton(
          label: actionLabel,
          icon: section == 'Find'
              ? FluentIcons.search_24_regular
              : FluentIcons.video_24_regular,
          primary: true,
          onPressed: () {},
        ),
        const SizedBox(height: 8),
        _CommandButton(
          label: section == 'Find' ? 'Clear Results' : 'Stop',
          icon: section == 'Find'
              ? FluentIcons.delete_24_regular
              : FluentIcons.stop_24_regular,
          onPressed: () {},
        ),
        const Spacer(),
        const Text(
          'Actions are visual placeholders.',
          style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
        ),
      ],
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
  const _BottomBar({
    required this.feedLabel,
    required this.feedOptions,
    required this.selectedFeed,
    required this.onFeedChanged,
    required this.selectedLayout,
    required this.onLayoutChanged,
    required this.onOptions,
  });

  final String feedLabel;
  final List<String> feedOptions;
  final String? selectedFeed;
  final ValueChanged<String?> onFeedChanged;
  final String? selectedLayout;
  final ValueChanged<String?> onLayoutChanged;
  final VoidCallback onOptions;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 900;
        final optionsButton = Button(
          onPressed: onOptions,
          child: const Row(
            children: [
              Icon(FluentIcons.options_24_regular, size: 18),
              SizedBox(width: 8),
              Text('Options'),
            ],
          ),
        );
        final feedDropdown = _Dropdown(
          value: selectedFeed,
          options: feedOptions,
          onChanged: onFeedChanged,
        );
        final layoutDropdown = _Dropdown(
          value: selectedLayout,
          options: const ['Default', 'Compact', 'Expanded'],
          onChanged: onLayoutChanged,
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
                        const SizedBox(width: 12),
                        optionsButton,
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
                    const Spacer(),
                    optionsButton,
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

class _SettingsPage extends StatelessWidget {
  const _SettingsPage({required this.onOptions});

  final VoidCallback onOptions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings', style: FluentTheme.of(context).typography.title),
          const SizedBox(height: 8),
          const Text(
            'Configure the desktop interface. Feed and analysis settings are placeholders.',
          ),
          const SizedBox(height: 20),
          const _SettingRow(
            icon: FluentIcons.video_24_regular,
            title: 'Preview quality',
            description: 'Choose the display quality for the feed preview.',
            child: _Dropdown(
              value: 'Standard',
              options: ['Standard', 'High'],
              onChanged: _ignoreSelection,
            ),
          ),
          const Divider(),
          const _SettingRow(
            icon: FluentIcons.arrow_expand_24_regular,
            title: 'Workspace layout',
            description: 'Choose how panels are arranged.',
            child: _Dropdown(
              value: 'Classic',
              options: ['Classic', 'Compact'],
              onChanged: _ignoreSelection,
            ),
          ),
          const Spacer(),
          Button(onPressed: onOptions, child: const Text('Return to console')),
        ],
      ),
    );
  }
}

void _ignoreSelection(String? value) {}

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
      padding: const EdgeInsets.symmetric(vertical: 12),
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
                Text(description, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          SizedBox(width: 180, child: child),
        ],
      ),
    );
  }
}

class _HintsPage extends StatelessWidget {
  const _HintsPage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hints', style: FluentTheme.of(context).typography.title),
          const SizedBox(height: 16),
          const InfoBar(
            title: Text('Getting started'),
            content: Text(
              'Choose Find or Track, select a feed, then use the command panel. '
              'These controls are placeholders in the current UI phase.',
            ),
            severity: InfoBarSeverity.info,
          ),
        ],
      ),
    );
  }
}
