import 'package:flutter/material.dart';

void main() {
  runApp(const GodsEyeApp());
}

const _windowBlue = Color(0xFF2F6FB2);
const _dialogGray = Color(0xFFECE9D8);
const _lineGray = Color(0xFF9A9A9A);

class GodsEyeApp extends StatelessWidget {
  const GodsEyeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "God's Eye",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        fontFamily: 'Tahoma',
        scaffoldBackgroundColor: const Color(0xFFB7C7D8),
        colorScheme: ColorScheme.fromSeed(seedColor: _windowBlue),
      ),
      home: const AdminLoginScreen(),
    );
  }
}

class AdminLoginScreen extends StatelessWidget {
  const AdminLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: _WindowFrame(
            title: "God's Eye - Admin Login",
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.remove_red_eye_outlined,
                    size: 42,
                    color: _windowBlue,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Administrator sign in",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 18),
                  const _LabeledField(label: 'User name'),
                  const SizedBox(height: 12),
                  const _LabeledField(label: 'Password', obscureText: true),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _ClassicButton(
                        label: 'Exit',
                        onPressed: () {},
                        width: 92,
                      ),
                      const SizedBox(width: 10),
                      _ClassicButton(
                        label: 'Sign in',
                        isPrimary: true,
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute<void>(
                              builder: (_) => const MainWindow(),
                            ),
                          );
                        },
                        width: 100,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'UI preview only - sign-in is not connected to an account.',
                    style: TextStyle(fontSize: 11, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
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
  String _section = 'Find';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: _WindowFrame(
            title: "God's Eye - Surveillance Console",
            child: Column(
              children: [
                _SectionTabs(
                  selected: _section,
                  onSelected: (value) => setState(() => _section = value),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                    child: _section == 'Settings'
                        ? const _SettingsPanel()
                        : _section == 'Hints'
                        ? const _HintsPanel()
                        : _ConsolePanel(section: _section),
                  ),
                ),
                _BottomControls(section: _section),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConsolePanel extends StatelessWidget {
  const _ConsolePanel({required this.section});

  final String section;

  @override
  Widget build(BuildContext context) {
    final isFind = section == 'Find';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 5,
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: _Panel(
                  title: 'Camera feed',
                  child: const _FeedPlaceholder(),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                flex: 2,
                child: _Panel(
                  title: isFind ? 'Search results' : 'Track log',
                  child: const _LogPlaceholder(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 150,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '$section actions',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _ClassicButton(label: 'Load Feed', onPressed: () {}),
              const SizedBox(height: 8),
              _ClassicButton(
                label: isFind ? 'Search' : 'Track',
                onPressed: () {},
              ),
              const SizedBox(height: 8),
              _ClassicButton(
                label: isFind ? 'Clear Results' : 'Stop Track',
                onPressed: () {},
              ),
              const Spacer(),
              const Text(
                'Controls are placeholders in this UI preview.',
                style: TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FeedPlaceholder extends StatelessWidget {
  const _FeedPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF20252B),
      alignment: Alignment.center,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.videocam_outlined, size: 42, color: Colors.white70),
          SizedBox(height: 8),
          Text(
            'No camera feed loaded',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          SizedBox(height: 4),
          Text(
            'Static preview area',
            style: TextStyle(color: Colors.white60, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _LogPlaceholder extends StatelessWidget {
  const _LogPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      child: const Text(
        'No results to display.',
        style: TextStyle(color: Colors.black54),
      ),
    );
  }
}

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Settings',
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Display and feed preferences'),
            SizedBox(height: 12),
            _LabeledDropdown(
              label: 'Preview quality',
              values: ['Standard', 'High'],
            ),
            SizedBox(height: 12),
            _LabeledDropdown(label: 'Layout', values: ['Classic', 'Compact']),
            SizedBox(height: 18),
            Text(
              'Settings are visual placeholders; no feeds or analysis are configured.',
              style: TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class _HintsPanel extends StatelessWidget {
  const _HintsPanel();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Hints',
      child: const Padding(
        padding: EdgeInsets.all(14),
        child: Text('Helpful usage notes will appear here.'),
      ),
    );
  }
}

class _BottomControls extends StatelessWidget {
  const _BottomControls({required this.section});

  final String section;

  @override
  Widget build(BuildContext context) {
    final feedOptions = section == 'Track'
        ? ['Track feed...', 'Camera 1', 'Camera 2']
        : ['Find feed...', 'North Gate', 'Lobby'];
    final feedLabel = section == 'Track' ? 'Track feed' : 'Find feed';
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _lineGray)),
        color: _dialogGray,
      ),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: Row(
        children: [
          Expanded(
            child: _LabeledDropdown(label: feedLabel, values: feedOptions),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: _LabeledDropdown(
              label: 'Profile',
              values: ['Default', 'Custom'],
            ),
          ),
          const SizedBox(width: 16),
          _ClassicButton(label: 'Options', onPressed: () {}),
          const SizedBox(width: 8),
          _ClassicButton(label: 'Exit', onPressed: () {}),
        ],
      ),
    );
  }
}

class _SectionTabs extends StatelessWidget {
  const _SectionTabs({required this.selected, required this.onSelected});

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      decoration: const BoxDecoration(
        color: _dialogGray,
        border: Border(bottom: BorderSide(color: _lineGray)),
      ),
      child: Row(
        children: ['Find', 'Track', 'Settings', 'Hints'].map((section) {
          final active = section == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: InkWell(
              onTap: () => onSelected(section),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: active
                      ? const Color(0xFFF7F6EF)
                      : const Color(0xFFD8D5C7),
                  border: Border.all(color: active ? Colors.white : _lineGray),
                ),
                child: Text(
                  section,
                  style: TextStyle(
                    fontWeight: active ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: _lineGray),
              color: const Color(0xFFF7F6EF),
            ),
            child: child,
          ),
        ),
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, this.obscureText = false});

  final String label;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 88, child: Text('$label:')),
        Expanded(
          child: SizedBox(
            height: 32,
            child: TextField(
              obscureText: obscureText,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: _lineGray),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: _lineGray),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LabeledDropdown extends StatelessWidget {
  const _LabeledDropdown({required this.label, required this.values});

  final String label;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('$label: '),
        Expanded(
          child: SizedBox(
            height: 30,
            child: DropdownButtonFormField<String>(
              initialValue: values.first,
              isExpanded: true,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: _lineGray),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: _lineGray),
                ),
              ),
              items: values
                  .map(
                    (value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: (_) {},
            ),
          ),
        ),
      ],
    );
  }
}

class _ClassicButton extends StatelessWidget {
  const _ClassicButton({
    required this.label,
    required this.onPressed,
    this.width,
    this.isPrimary = false,
  });

  final String label;
  final VoidCallback onPressed;
  final double? width;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 32,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: isPrimary ? const Color(0xFFDDEEFF) : _dialogGray,
          side: BorderSide(color: isPrimary ? _windowBlue : _lineGray),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        ),
        child: Text(label, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

class _WindowFrame extends StatelessWidget {
  const _WindowFrame({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _dialogGray,
        border: Border.all(color: const Color(0xFF5D7892), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55000000),
            blurRadius: 12,
            offset: Offset(3, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF5C9CE0), Color(0xFF1F5EA5)],
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.remove_red_eye_outlined,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  width: 22,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCB514A),
                    border: Border.all(color: Colors.white70),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Text(
                    '×',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      height: 1,
                      fontWeight: FontWeight.bold,
                    ),
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
