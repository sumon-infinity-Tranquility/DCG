import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() {
  runApp(const DcgApp());
}

class DcgApp extends StatelessWidget {
  const DcgApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DCG',
      debugShowCheckedModeBanner: false,
      theme: DcgTheme.light,
      home: const AuthGate(),
    );
  }
}

class DcgTheme {
  static const bg = Color(0xFFF5F5FA);
  static const surface = Color(0xFFFFFFFF);
  static const slate = Color(0xFF313A51);
  static const muted = Color(0xFF747B8F);
  static const line = Color(0xFFE2E5EE);
  static const accent = Color(0xFFFF8852);
  static const accentSoft = Color(0xFFFFF1EA);
  static const danger = Color(0xFFE34242);
  static const green = Color(0xFF16A274);
  static const blue = Color(0xFF4D74FF);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(seedColor: accent, brightness: Brightness.light);

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: bg,
      colorScheme: scheme.copyWith(primary: accent, secondary: slate, surface: surface, error: danger),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: slate, height: 1.05),
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: slate, height: 1.12),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: slate),
        titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: slate),
        bodyLarge: TextStyle(fontSize: 15, color: slate, height: 1.45),
        bodyMedium: TextStyle(fontSize: 13, color: muted, height: 1.45),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: false,
        foregroundColor: slate,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: line)),
        enabledBorder:
            OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: line)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: accent, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          elevation: 0,
          backgroundColor: accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          foregroundColor: slate,
          side: const BorderSide(color: line),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

enum CaseStatus { open, triage, responding, resolved }

enum Priority { low, medium, high, critical }

class EmergencyCategory {
  const EmergencyCategory(this.name, this.icon, this.color, this.helpText);

  final String name;
  final IconData icon;
  final Color color;
  final String helpText;
}

class DcgCase {
  DcgCase({
    required this.id,
    required this.name,
    required this.contact,
    required this.role,
    required this.category,
    required this.location,
    required this.priority,
    required this.status,
    required this.details,
    required this.createdAt,
    this.updatedAt,
    this.updatedBy,
  });

  final String id;
  final String name;
  final String contact;
  final String role;
  final String category;
  final String location;
  final Priority priority;
  CaseStatus status;
  final String details;
  final DateTime createdAt;
  DateTime? updatedAt;
  String? updatedBy;
}

class ResponderContact {
  const ResponderContact(this.name, this.role, this.phone, this.online);

  final String name;
  final String role;
  final String phone;
  final bool online;
}

class DcgUser {
  const DcgUser({
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
    required this.department,
  });

  final String name;
  final String email;
  final String role;
  final String phone;
  final String department;

  DcgUser copyWith({
    String? name,
    String? email,
    String? role,
    String? phone,
    String? department,
  }) {
    return DcgUser(
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      department: department ?? this.department,
    );
  }
}

class AuthRecord {
  const AuthRecord({required this.user, required this.password});

  final DcgUser user;
  final String password;
}

class DemoAuthStore {
  static final Map<String, AuthRecord> _records = {
    'responder@diu.edu.bd': const AuthRecord(
      password: '123456',
      user: DcgUser(
        name: 'Campus Responder',
        email: 'responder@diu.edu.bd',
        role: 'Responder',
        phone: '+8801713493050',
        department: 'Proctor Office',
      ),
    ),
  };

  static String normalize(String email) => email.trim().toLowerCase();

  static DcgUser signIn({required String email, required String password}) {
    final record = _records[normalize(email)];
    if (record == null) {
      throw const AuthException('No account found for this email.');
    }
    if (record.password != password) {
      throw const AuthException('Password does not match.');
    }
    return record.user;
  }

  static DcgUser signUp({
    required String name,
    required String email,
    required String password,
    required String role,
    required String phone,
  }) {
    final key = normalize(email);
    if (_records.containsKey(key)) {
      throw const AuthException('An account already exists. Please sign in.');
    }
    final user = DcgUser(
      name: name.trim().isEmpty ? 'Campus Responder' : name.trim(),
      email: key,
      role: role,
      phone: phone.trim().isEmpty ? '+8801700000000' : phone.trim(),
      department: role == 'Student' ? 'Student Affairs' : 'Proctor Office',
    );
    _records[key] = AuthRecord(user: user, password: password);
    return user;
  }

  static void updateUser(DcgUser user) {
    final key = normalize(user.email);
    final current = _records[key];
    _records[key] = AuthRecord(user: user, password: current?.password ?? '123456');
  }
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;
}

const categories = [
  EmergencyCategory('Medical', Icons.medical_services_rounded, Color(0xFFDCE991), 'Health, injury, ambulance'),
  EmergencyCategory('Violence', Icons.security_rounded, Color(0xFFF5A6DF), 'Threat, harassment, crowd risk'),
  EmergencyCategory('Rescue', Icons.volunteer_activism_rounded, Color(0xFFF5E8A6), 'Stuck, trapped, urgent help'),
  EmergencyCategory('Fire', Icons.local_fire_department_rounded, Color(0xFFF5A6A6), 'Smoke, fire, electrical hazard'),
  EmergencyCategory('Disaster', Icons.storm_rounded, Color(0xFFA6F5D4), 'Storm, earthquake, flood'),
  EmergencyCategory('Accident', Icons.car_crash_rounded, Color(0xFFD4CEF9), 'Transport or campus accident'),
];

const contacts = [
  ResponderContact('Proctor Office', 'Campus response lead', '+8801713493050', true),
  ResponderContact('Medical Center', 'First aid and ambulance', '+8801847334655', true),
  ResponderContact('Security Control', 'Gate and patrol unit', '+8801912400700', true),
  ResponderContact('Transport Desk', 'Campus route support', '+8801811110001', false),
];

final seedCases = <DcgCase>[
  DcgCase(
    id: '1',
    name: 'Proctor Office',
    contact: '+8801713493050',
    role: 'Safety team',
    category: 'Violence',
    location: 'Main Campus Gate',
    priority: Priority.high,
    status: CaseStatus.responding,
    details: 'Crowd pressure reported near the gate. Safety team is monitoring.',
    createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
  ),
  DcgCase(
    id: '2',
    name: 'Transport Desk',
    contact: '+8801811110001',
    role: 'Staff',
    category: 'Accident',
    location: 'Bus Stand',
    priority: Priority.medium,
    status: CaseStatus.open,
    details: 'Minor transport incident reported. Route support requested.',
    createdAt: DateTime.now().subtract(const Duration(minutes: 24)),
  ),
  DcgCase(
    id: '3',
    name: 'Medical Center',
    contact: '+8801847334655',
    role: 'Staff',
    category: 'Medical',
    location: 'Knowledge Tower',
    priority: Priority.low,
    status: CaseStatus.resolved,
    details: 'First-aid support completed on level 2.',
    createdAt: DateTime.now().subtract(const Duration(hours: 1)),
  ),
];

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  DcgUser? currentUser;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 420),
      child: currentUser != null
          ? DcgHome(
              key: const ValueKey('home'),
              initialUser: currentUser!,
              onSignOut: () => setState(() => currentUser = null),
            )
          : AuthScreen(
              key: const ValueKey('auth'),
              onSignedIn: (user) => setState(() => currentUser = user),
            ),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({required this.onSignedIn, super.key});

  final ValueChanged<DcgUser> onSignedIn;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: 'Campus Responder');
  final emailController = TextEditingController(text: 'responder@diu.edu.bd');
  final passwordController = TextEditingController(text: '123456');
  final phoneController = TextEditingController(text: '+8801713493050');
  bool createAccount = false;
  bool showPassword = false;
  bool busy = false;
  int roleIndex = 0;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void submit() {
    if (!(formKey.currentState?.validate() ?? false)) return;

    setState(() => busy = true);
    try {
      final user = createAccount
          ? DemoAuthStore.signUp(
              name: nameController.text,
              email: emailController.text,
              password: passwordController.text,
              role: roles[roleIndex],
              phone: phoneController.text,
            )
          : DemoAuthStore.signIn(
              email: emailController.text,
              password: passwordController.text,
            );
      widget.onSignedIn(user);
    } on AuthException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  static const roles = ['Responder', 'Student', 'Staff'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 26),
          children: [
            const BrandLockup(),
            const SizedBox(height: 24),
            AppCard(
              color: DcgTheme.slate,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(color: DcgTheme.accent, borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.sos_rounded, color: Colors.white),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Fast campus emergency response',
                    style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, height: 1.05),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Sign in, trigger SOS, submit reports, and coordinate responders from one mobile app.',
                    style: TextStyle(color: Color(0xFFDDE2EF), height: 1.45),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: const [
                      MiniStat(label: 'Teams', value: '6'),
                      SizedBox(width: 10),
                      MiniStat(label: 'Avg', value: '4m'),
                      SizedBox(width: 10),
                      MiniStat(label: 'Live', value: '24/7'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            AppCard(
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 240),
                      child: Text(
                        createAccount ? 'Create account' : 'Sign in',
                        key: ValueKey(createAccount),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SegmentedButton<int>(
                      segments: [
                        for (var i = 0; i < roles.length; i++) ButtonSegment(value: i, label: Text(roles[i])),
                      ],
                      selected: {roleIndex},
                      onSelectionChanged: (value) => setState(() => roleIndex = value.first),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (value) => createAccount ? requiredValidator(value) : null,
                    ),
                    const SizedBox(height: 12),
                    if (createAccount) ...[
                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: 'Phone', prefixIcon: Icon(Icons.call_rounded)),
                        validator: requiredValidator,
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.mail_rounded)),
                      validator: (value) => value != null && value.contains('@') ? null : 'Enter a valid email',
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: passwordController,
                      obscureText: !showPassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_rounded),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => showPassword = !showPassword),
                          icon: Icon(showPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                        ),
                      ),
                      validator: (value) => value != null && value.length >= 6 ? null : 'Use at least 6 characters',
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: busy ? null : submit,
                      child: busy
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(createAccount ? 'Create and continue' : 'Sign in'),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () => widget.onSignedIn(
                        DcgUser(
                          name: nameController.text.trim().isEmpty ? 'Google Responder' : nameController.text.trim(),
                          email: emailController.text.trim().isEmpty ? 'google@diu.edu.bd' : emailController.text.trim(),
                          role: roles[roleIndex],
                          phone: phoneController.text.trim().isEmpty ? '+8801700000000' : phoneController.text.trim(),
                          department: 'Google Auth Demo',
                        ),
                      ),
                      icon: const Icon(Icons.g_mobiledata_rounded),
                      label: const Text('Continue with Google'),
                    ),
                    Center(
                      child: TextButton(
                        onPressed: () => setState(() {
                          createAccount = !createAccount;
                          if (createAccount && emailController.text == 'responder@diu.edu.bd') {
                            emailController.text = '';
                            passwordController.text = '';
                          }
                        }),
                        child: Text(createAccount ? 'Already have an account?' : 'Create a new account'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DcgHome extends StatefulWidget {
  const DcgHome({required this.initialUser, required this.onSignOut, super.key});

  final DcgUser initialUser;
  final VoidCallback onSignOut;

  @override
  State<DcgHome> createState() => _DcgHomeState();
}

class _DcgHomeState extends State<DcgHome> {
  int tabIndex = 0;
  final cases = List<DcgCase>.from(seedCases);
  final pageController = PageController();
  late DcgUser user;

  @override
  void initState() {
    super.initState();
    user = widget.initialUser;
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void addCase(DcgCase dcgCase) {
    setState(() => cases.insert(0, dcgCase));
  }

  void updateStatus(DcgCase dcgCase, CaseStatus status) {
    setState(() {
      dcgCase.status = status;
      dcgCase.updatedAt = DateTime.now();
      dcgCase.updatedBy = user.name;
    });
    showSnack('${dcgCase.location} moved to ${status.label}');
  }

  void showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void selectTab(int index) {
    setState(() => tabIndex = index);
    pageController.animateToPage(index, duration: const Duration(milliseconds: 280), curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(
        user: user,
        cases: cases,
        onOpenSos: () => selectTab(1),
        onOpenProfile: () => selectTab(5),
        onSelectCategory: (category) => showReportSheet(category.name),
      ),
      SosPage(
        responderName: user.name,
        onCreateCase: (dcgCase) {
          addCase(dcgCase);
          showSnack('Critical SOS case created');
        },
      ),
      ReportHubPage(
        onStartReport: (category) => showReportSheet(category),
      ),
      CasesPage(cases: cases, onStatusChange: updateStatus),
      ContactsPage(),
      ProfilePage(
        user: user,
        cases: cases,
        onSave: (updatedUser) {
          setState(() => user = updatedUser);
          DemoAuthStore.updateUser(updatedUser);
          showSnack('Profile updated');
        },
        onSignOut: widget.onSignOut,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: const BrandLockup(compact: true),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: widget.onSignOut,
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: (index) => setState(() => tabIndex = index),
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tabIndex,
        onDestinationSelected: selectTab,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.sos_rounded), label: 'SOS'),
          NavigationDestination(icon: Icon(Icons.edit_note_rounded), label: 'Report'),
          NavigationDestination(icon: Icon(Icons.view_kanban_rounded), label: 'Cases'),
          NavigationDestination(icon: Icon(Icons.call_rounded), label: 'Contacts'),
          NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }

  Future<void> showReportSheet(String category) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => ReportSheet(
        initialCategory: category,
        responderName: user.name,
        onSubmit: (dcgCase) {
          addCase(dcgCase);
          showSnack('Report submitted');
        },
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    required this.user,
    required this.cases,
    required this.onOpenSos,
    required this.onOpenProfile,
    required this.onSelectCategory,
    super.key,
  });

  final DcgUser user;
  final List<DcgCase> cases;
  final VoidCallback onOpenSos;
  final VoidCallback onOpenProfile;
  final ValueChanged<EmergencyCategory> onSelectCategory;

  @override
  Widget build(BuildContext context) {
    final open = cases.where((item) => item.status != CaseStatus.resolved).length;
    final critical = cases.where((item) => item.priority == Priority.critical).length;
    final responding = cases.where((item) => item.status == CaseStatus.responding).length;
    final submittedByUser = cases.where((item) => item.name == user.name).length;
    final latest = cases.take(3).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hi, ${user.name}', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 5),
                  Text('${user.role} - ${user.department}',
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            LiveBadge(text: '$responding live'),
          ],
        ),
        const SizedBox(height: 18),
        AppCard(
          padding: EdgeInsets.zero,
          clip: true,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [DcgTheme.slate, Color(0xFF45516E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Need urgent help?',
                            style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900),
                          ),
                        ),
                        IconButton.filled(
                          onPressed: onOpenSos,
                          style: IconButton.styleFrom(backgroundColor: DcgTheme.accent),
                          icon: const Icon(Icons.sos_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Open SOS, choose the emergency type, then hold to alert responders.',
                      style: TextStyle(color: Color(0xFFDDE2EF), height: 1.4),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Expanded(child: MetricPill(label: 'Open', value: '$open')),
                    const SizedBox(width: 10),
                    Expanded(child: MetricPill(label: 'Critical', value: '$critical', danger: true)),
                    const SizedBox(width: 10),
                    Expanded(child: MetricPill(label: 'Mine', value: '$submittedByUser')),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        SectionTitle(title: 'Responder dashboard', action: 'Profile', onAction: onOpenProfile),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            children: [
              DashboardProgress(label: 'Campus coverage', value: 0.82, color: DcgTheme.green),
              const SizedBox(height: 12),
              DashboardProgress(label: 'Critical readiness', value: critical == 0 ? 0.35 : 0.72, color: DcgTheme.accent),
              const SizedBox(height: 12),
              DashboardProgress(label: 'Case resolution', value: cases.isEmpty ? 0 : cases.where((item) => item.status == CaseStatus.resolved).length / cases.length, color: DcgTheme.blue),
            ],
          ),
        ),
        const SizedBox(height: 22),
        SectionTitle(
          title: 'What is your emergency?',
          action: 'Tap to report',
          onAction: () => onSelectCategory(categories.first),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 128,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) => SizedBox(
              width: 142,
              child: CategoryTile(category: categories[index], onTap: () => onSelectCategory(categories[index])),
            ),
          ),
        ),
        const SizedBox(height: 22),
        SectionTitle(title: 'Latest activity', action: 'View cases', onAction: () {}),
        const SizedBox(height: 12),
        for (final item in latest) CompactCaseTile(dcgCase: item),
      ],
    );
  }
}

class SosPage extends StatefulWidget {
  const SosPage({required this.responderName, required this.onCreateCase, super.key});

  final String responderName;
  final ValueChanged<DcgCase> onCreateCase;

  @override
  State<SosPage> createState() => _SosPageState();
}

class _SosPageState extends State<SosPage> with SingleTickerProviderStateMixin {
  late final AnimationController pulseController;
  Timer? holdTimer;
  double holdProgress = 0;
  bool calling = false;
  String selectedCategory = categories.first.name;
  final timeline = <String>[
    'Ready to share campus location',
    'Emergency contacts standing by',
    'Nearest help centre available',
  ];

  @override
  void initState() {
    super.initState();
    pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    holdTimer?.cancel();
    pulseController.dispose();
    super.dispose();
  }

  void startHold() {
    if (holdTimer != null) return;
    setState(() {
      calling = true;
      holdProgress = 0;
    });
    holdTimer = Timer.periodic(const Duration(milliseconds: 60), (_) {
      setState(() => holdProgress = (holdProgress + 0.02).clamp(0, 1));
      if (holdProgress >= 1) finishHold();
    });
  }

  void cancelHold() {
    if (holdProgress >= 1) return;
    holdTimer?.cancel();
    holdTimer = null;
    setState(() {
      calling = false;
      holdProgress = 0;
    });
  }

  void finishHold() {
    holdTimer?.cancel();
    holdTimer = null;
    final dcgCase = DcgCase(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: widget.responderName,
      contact: '+8801713493050',
      role: 'Responder',
      category: selectedCategory,
      location: 'Live campus location',
      priority: Priority.critical,
      status: CaseStatus.open,
      details: 'SOS triggered. Live location shared with nearest help centre and emergency contacts.',
      createdAt: DateTime.now(),
    );
    widget.onCreateCase(dcgCase);
    setState(() {
      calling = false;
      holdProgress = 0;
      timeline.insert(0, 'Critical $selectedCategory case created now');
      timeline.insert(1, 'Location sent to Proctor Office');
    });
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SosResultSheet(category: selectedCategory),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        Text('SOS Emergency', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text('Choose the emergency type, then hold the SOS button until the ring completes.',
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 18),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final category = categories[index];
              final selected = selectedCategory == category.name;
              return ChoiceChip(
                selected: selected,
                avatar: Icon(category.icon, size: 18),
                label: Text(category.name),
                onSelected: (_) => setState(() => selectedCategory = category.name),
              );
            },
          ),
        ),
        const SizedBox(height: 28),
        Center(
          child: GestureDetector(
            onTapDown: (_) => startHold(),
            onTapCancel: cancelHold,
            onTapUp: (_) => cancelHold(),
            child: AnimatedBuilder(
              animation: pulseController,
              builder: (context, child) {
                return CustomPaint(
                  painter: SosPulsePainter(
                    pulse: pulseController.value,
                    progress: holdProgress,
                    calling: calling,
                  ),
                  child: child,
                );
              },
              child: AnimatedScale(
                duration: const Duration(milliseconds: 160),
                scale: calling ? 0.96 : 1,
                child: Container(
                  width: 238,
                  height: 238,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: DcgTheme.accent),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        calling ? '${(holdProgress * 100).round()}%' : 'SOS',
                        style: const TextStyle(color: Colors.white, fontSize: 52, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        calling ? 'Keep holding' : 'Press and hold',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Live response timeline', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              for (var i = 0; i < math.min(timeline.length, 5); i++)
                TimelineRow(text: timeline[i], active: i == 0),
            ],
          ),
        ),
        const SizedBox(height: 14),
        AppCard(
          color: DcgTheme.accentSoft,
          child: Row(
            children: [
              const Icon(Icons.location_on_rounded, color: DcgTheme.accent),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Demo map: live campus location, nearest help centre, and emergency contacts are simulated here.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ReportHubPage extends StatelessWidget {
  const ReportHubPage({required this.onStartReport, super.key});

  final ValueChanged<String> onStartReport;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        Text('Quick report', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text('Pick a category to open a focused report form.', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 18),
        for (final category in categories)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => onStartReport(category.name),
              child: AppCard(
                child: Row(
                  children: [
                    CategoryIcon(category: category, size: 52),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(category.name, style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 4),
                          Text(category.helpText, style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class CasesPage extends StatefulWidget {
  const CasesPage({required this.cases, required this.onStatusChange, super.key});

  final List<DcgCase> cases;
  final void Function(DcgCase dcgCase, CaseStatus status) onStatusChange;

  @override
  State<CasesPage> createState() => _CasesPageState();
}

class _CasesPageState extends State<CasesPage> {
  String query = '';
  CaseStatus? filterStatus;

  @override
  Widget build(BuildContext context) {
    final filtered = widget.cases.where((item) {
      final text = '${item.name} ${item.category} ${item.location} ${item.details}'.toLowerCase();
      final queryOk = query.isEmpty || text.contains(query.toLowerCase());
      final statusOk = filterStatus == null || item.status == filterStatus;
      return queryOk && statusOk;
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        Text('Cases', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 12),
        TextField(
          onChanged: (value) => setState(() => query = value),
          decoration: const InputDecoration(
            hintText: 'Search location, reporter, details',
            prefixIcon: Icon(Icons.search_rounded),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FilterChip(
                selected: filterStatus == null,
                label: const Text('All'),
                onSelected: (_) => setState(() => filterStatus = null),
              ),
              const SizedBox(width: 8),
              for (final status in CaseStatus.values) ...[
                FilterChip(
                  selected: filterStatus == status,
                  label: Text(status.label),
                  onSelected: (_) => setState(() => filterStatus = status),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (filtered.isEmpty)
          const EmptyState(message: 'No matching cases.')
        else
          ...filtered.map(
            (item) => CaseCard(
              dcgCase: item,
              onStatusChange: (status) => widget.onStatusChange(item, status),
            ),
          ),
      ],
    );
  }
}

class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        Text('Emergency contacts', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text('Tap a card action for immediate feedback. Phone integration can be enabled with url_launcher later.',
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 18),
        for (final contact in contacts)
          AppCard(
            margin: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: contact.online ? const Color(0xFFE7F8F1) : const Color(0xFFEFF2F7),
                  child: Icon(Icons.call_rounded, color: contact.online ? DcgTheme.green : DcgTheme.muted),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(contact.name, style: Theme.of(context).textTheme.titleMedium)),
                          LiveBadge(text: contact.online ? 'online' : 'standby', muted: !contact.online),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(contact.role, style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 4),
                      Text(contact.phone, style: const TextStyle(fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$value ${contact.phone}')),
                  ),
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'Calling', child: Text('Call')),
                    PopupMenuItem(value: 'Copied', child: Text('Copy number')),
                    PopupMenuItem(value: 'Shared', child: Text('Share case')),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    required this.user,
    required this.cases,
    required this.onSave,
    required this.onSignOut,
    super.key,
  });

  final DcgUser user;
  final List<DcgCase> cases;
  final ValueChanged<DcgUser> onSave;
  final VoidCallback onSignOut;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;
  late final TextEditingController departmentController;
  late String role;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user.name);
    emailController = TextEditingController(text: widget.user.email);
    phoneController = TextEditingController(text: widget.user.phone);
    departmentController = TextEditingController(text: widget.user.department);
    role = widget.user.role;
  }

  @override
  void didUpdateWidget(covariant ProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user != widget.user) {
      nameController.text = widget.user.name;
      emailController.text = widget.user.email;
      phoneController.text = widget.user.phone;
      departmentController.text = widget.user.department;
      role = widget.user.role;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    departmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myCases = widget.cases.where((item) => item.name == widget.user.name).length;
    final resolved = widget.cases.where((item) => item.updatedBy == widget.user.name && item.status == CaseStatus.resolved).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        Text('User profile', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text('Manage responder identity and account details for the app session.',
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 18),
        AppCard(
          color: DcgTheme.slate,
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: DcgTheme.accent,
                child: Text(
                  widget.user.name.isEmpty ? 'D' : widget.user.name[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.user.name,
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text('${widget.user.role} - ${widget.user.department}',
                        style: const TextStyle(color: Color(0xFFDDE2EF))),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: MetricPill(label: 'My reports', value: '$myCases')),
            const SizedBox(width: 10),
            Expanded(child: MetricPill(label: 'Resolved', value: '$resolved')),
            const SizedBox(width: 10),
            const Expanded(child: MetricPill(label: 'Trust', value: 'A+')),
          ],
        ),
        const SizedBox(height: 18),
        AppCard(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Full name', prefixIcon: Icon(Icons.person_rounded)),
                  validator: requiredValidator,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.mail_rounded)),
                  validator: (value) => value != null && value.contains('@') ? null : 'Enter a valid email',
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone', prefixIcon: Icon(Icons.call_rounded)),
                  validator: requiredValidator,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: role,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: ['Responder', 'Student', 'Staff']
                      .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                      .toList(),
                  onChanged: (value) => setState(() => role = value ?? role),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: departmentController,
                  decoration: const InputDecoration(labelText: 'Department', prefixIcon: Icon(Icons.apartment_rounded)),
                  validator: requiredValidator,
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: () {
                    if (!(formKey.currentState?.validate() ?? false)) return;
                    widget.onSave(
                      widget.user.copyWith(
                        name: nameController.text.trim(),
                        email: emailController.text.trim().toLowerCase(),
                        role: role,
                        phone: phoneController.text.trim(),
                        department: departmentController.text.trim(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.save_rounded),
                  label: const Text('Save profile'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: widget.onSignOut,
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Sign out'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ReportSheet extends StatefulWidget {
  const ReportSheet({
    required this.initialCategory,
    required this.responderName,
    required this.onSubmit,
    super.key,
  });

  final String initialCategory;
  final String responderName;
  final ValueChanged<DcgCase> onSubmit;

  @override
  State<ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<ReportSheet> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final contactController = TextEditingController();
  final locationController = TextEditingController();
  final detailsController = TextEditingController();
  String role = 'Student';
  String category = categories.first.name;
  Priority priority = Priority.medium;

  @override
  void initState() {
    super.initState();
    category = widget.initialCategory;
  }

  @override
  void dispose() {
    nameController.dispose();
    contactController.dispose();
    locationController.dispose();
    detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.96,
      builder: (context, scrollController) {
        return ListView(
          controller: scrollController,
          padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 24),
          children: [
            Text('Submit campus report', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 6),
            Text('This report becomes a live case for responders.', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Reporter name', prefixIcon: Icon(Icons.person_rounded)),
                    validator: requiredValidator,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: contactController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Contact number', prefixIcon: Icon(Icons.call_rounded)),
                    validator: requiredValidator,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: locationController,
                    decoration: const InputDecoration(labelText: 'Location', prefixIcon: Icon(Icons.place_rounded)),
                    validator: requiredValidator,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: role,
                    decoration: const InputDecoration(labelText: 'Role'),
                    items: ['Student', 'Teacher', 'Staff', 'Alumni', 'Visitor']
                        .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                        .toList(),
                    onChanged: (value) => setState(() => role = value ?? role),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: category,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: categories
                        .map((item) => DropdownMenuItem(value: item.name, child: Text(item.name)))
                        .toList(),
                    onChanged: (value) => setState(() => category = value ?? category),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<Priority>(
                    segments: Priority.values
                        .map((item) => ButtonSegment(value: item, label: Text(item.label)))
                        .toList(),
                    selected: {priority},
                    onSelectionChanged: (value) => setState(() => priority = value.first),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: detailsController,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Details'),
                    validator: requiredValidator,
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: () {
                      if (!(formKey.currentState?.validate() ?? false)) return;
                      widget.onSubmit(
                        DcgCase(
                          id: DateTime.now().microsecondsSinceEpoch.toString(),
                          name: nameController.text,
                          contact: contactController.text,
                          role: role,
                          category: category,
                          location: locationController.text,
                          priority: priority,
                          status: CaseStatus.open,
                          details: detailsController.text,
                          createdAt: DateTime.now(),
                        ),
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('Submit report'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

String? requiredValidator(String? value) {
  if (value == null || value.trim().isEmpty) return 'Required';
  return null;
}

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.margin,
    this.color,
    this.padding = const EdgeInsets.all(16),
    this.clip = false,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final EdgeInsetsGeometry padding;
  final bool clip;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      clipBehavior: clip ? Clip.antiAlias : Clip.none,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? DcgTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color == null ? DcgTheme.line : Colors.transparent),
        boxShadow: [
          BoxShadow(color: DcgTheme.slate.withOpacity(0.07), blurRadius: 26, offset: const Offset(0, 14)),
        ],
      ),
      child: child,
    );
  }
}

class MetricPill extends StatelessWidget {
  const MetricPill({required this.label, required this.value, this.danger = false, super.key});

  final String label;
  final String value;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: danger ? DcgTheme.accentSoft : DcgTheme.bg, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: danger ? DcgTheme.accent : DcgTheme.slate)),
        ],
      ),
    );
  }
}

class DashboardProgress extends StatelessWidget {
  const DashboardProgress({
    required this.label,
    required this.value,
    required this.color,
    super.key,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: Theme.of(context).textTheme.titleMedium)),
            Text('${(clamped * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: clamped,
            minHeight: 9,
            backgroundColor: const Color(0xFFEFF2F7),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class CategoryTile extends StatelessWidget {
  const CategoryTile({required this.category, required this.onTap, super.key});

  final EmergencyCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CategoryIcon(category: category),
            const Spacer(),
            Text(category.name, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 3),
            Text(category.helpText, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class CategoryIcon extends StatelessWidget {
  const CategoryIcon({required this.category, this.size = 44, super.key});

  final EmergencyCategory category;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: category.color, borderRadius: BorderRadius.circular(14)),
      child: Icon(category.icon, color: DcgTheme.slate),
    );
  }
}

class CaseCard extends StatelessWidget {
  const CaseCard({required this.dcgCase, required this.onStatusChange, super.key});

  final DcgCase dcgCase;
  final ValueChanged<CaseStatus> onStatusChange;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        title: Text(dcgCase.location, style: Theme.of(context).textTheme.titleLarge),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              InfoChip(label: dcgCase.category),
              PriorityBadge(priority: dcgCase.priority),
              InfoChip(label: dcgCase.status.label),
            ],
          ),
        ),
        children: [
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(dcgCase.details, style: Theme.of(context).textTheme.bodyMedium),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: () => onStatusChange(CaseStatus.triage), child: const Text('Triage'))),
              const SizedBox(width: 10),
              Expanded(child: OutlinedButton(onPressed: () => onStatusChange(CaseStatus.responding), child: const Text('Respond'))),
              const SizedBox(width: 10),
              Expanded(child: ElevatedButton(onPressed: () => onStatusChange(CaseStatus.resolved), child: const Text('Done'))),
            ],
          ),
        ],
      ),
    );
  }
}

class CompactCaseTile extends StatelessWidget {
  const CompactCaseTile({required this.dcgCase, super.key});

  final DcgCase dcgCase;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          StatusDot(status: dcgCase.status),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dcgCase.location, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                Text('${dcgCase.category} - ${dcgCase.status.label}', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          PriorityBadge(priority: dcgCase.priority),
        ],
      ),
    );
  }
}

class PriorityBadge extends StatelessWidget {
  const PriorityBadge({required this.priority, super.key});

  final Priority priority;

  @override
  Widget build(BuildContext context) {
    final hot = priority == Priority.high || priority == Priority.critical;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: hot ? DcgTheme.danger : const Color(0xFFF4E4A7), borderRadius: BorderRadius.circular(999)),
      child: Text(
        priority.label,
        style: TextStyle(color: hot ? Colors.white : DcgTheme.slate, fontSize: 12, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class InfoChip extends StatelessWidget {
  const InfoChip({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(color: const Color(0xFFEFF2F7), borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
    );
  }
}

class LiveBadge extends StatelessWidget {
  const LiveBadge({required this.text, this.muted = false, super.key});

  final String text;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(color: muted ? const Color(0xFFEFF2F7) : const Color(0xFFE7F8F1), borderRadius: BorderRadius.circular(999)),
      child: Text(
        text,
        style: TextStyle(color: muted ? DcgTheme.muted : DcgTheme.green, fontSize: 12, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class StatusDot extends StatelessWidget {
  const StatusDot({required this.status, super.key});

  final CaseStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: status.color, shape: BoxShape.circle),
    );
  }
}

class TimelineRow extends StatelessWidget {
  const TimelineRow({required this.text, required this.active, super.key});

  final String text;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(color: active ? DcgTheme.accent : const Color(0xFFEFF2F7), shape: BoxShape.circle),
            child: Icon(active ? Icons.flash_on_rounded : Icons.check_rounded, size: 15, color: active ? Colors.white : DcgTheme.muted),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyLarge)),
        ],
      ),
    );
  }
}

class SosResultSheet extends StatelessWidget {
  const SosResultSheet({required this.category, super.key});

  final String category;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(color: DcgTheme.accentSoft, shape: BoxShape.circle),
            child: const Icon(Icons.sos_rounded, color: DcgTheme.accent),
          ),
          const SizedBox(height: 14),
          Text('Emergency request sent', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            '$category alert created. Please stand by while the nearest campus response team reviews your location.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('I understand')),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return AppCard(child: Center(child: Padding(padding: const EdgeInsets.all(18), child: Text(message))));
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({required this.title, this.action, this.onAction, super.key});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
        if (action != null) TextButton(onPressed: onAction, child: Text(action!)),
      ],
    );
  }
}

class MiniStat extends StatelessWidget {
  const MiniStat({required this.label, required this.value, super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
            Text(label, style: const TextStyle(color: Color(0xFFDDE2EF), fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class BrandLockup extends StatelessWidget {
  const BrandLockup({this.compact = false, super.key});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: compact ? 38 : 48,
          height: compact ? 38 : 48,
          decoration: BoxDecoration(
            color: DcgTheme.accent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              'D',
              style: TextStyle(color: Colors.white, fontSize: compact ? 18 : 24, fontWeight: FontWeight.w900),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('DCG', style: Theme.of(context).textTheme.titleLarge),
            if (!compact) Text('Daffodil CrisisGuard', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ],
    );
  }
}

class SosPulsePainter extends CustomPainter {
  SosPulsePainter({required this.pulse, required this.progress, required this.calling});

  final double pulse;
  final double progress;
  final bool calling;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final ripplePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = DcgTheme.accent.withOpacity(calling ? 0.22 : 0.12);

    for (var i = 0; i < 3; i++) {
      final r = radius + 10 + ((pulse + i / 3) % 1) * 36;
      canvas.drawCircle(center, r, ripplePaint..color = DcgTheme.accent.withOpacity((1 - ((pulse + i / 3) % 1)) * 0.18));
    }

    if (calling) {
      final progressPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 10
        ..color = DcgTheme.slate;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius + 12),
        -math.pi / 2,
        math.pi * 2 * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SosPulsePainter oldDelegate) {
    return pulse != oldDelegate.pulse || progress != oldDelegate.progress || calling != oldDelegate.calling;
  }
}

extension CaseStatusLabel on CaseStatus {
  String get label {
    switch (this) {
      case CaseStatus.open:
        return 'Open';
      case CaseStatus.triage:
        return 'Triage';
      case CaseStatus.responding:
        return 'Responding';
      case CaseStatus.resolved:
        return 'Resolved';
    }
  }

  Color get color {
    switch (this) {
      case CaseStatus.open:
        return DcgTheme.blue;
      case CaseStatus.triage:
        return DcgTheme.accent;
      case CaseStatus.responding:
        return DcgTheme.green;
      case CaseStatus.resolved:
        return DcgTheme.muted;
    }
  }
}

extension PriorityLabel on Priority {
  String get label {
    switch (this) {
      case Priority.low:
        return 'Low';
      case Priority.medium:
        return 'Medium';
      case Priority.high:
        return 'High';
      case Priority.critical:
        return 'Critical';
    }
  }
}
