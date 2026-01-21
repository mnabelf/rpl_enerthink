import 'package:flutter/material.dart';

void main() {
  runApp(const EnerThinkApp());
}

const Color kPrimaryColor = Color(0xFF10B981);

class EnerThinkApp extends StatelessWidget {
  const EnerThinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EnerThink',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF020617), // Slate 950
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimaryColor,
          brightness: Brightness.dark,
          primary: kPrimaryColor,
          surface: const Color(0xFF0F172A), // Slate 900
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

// --- MODELS ---
class ClassItem {
  final String title;
  final String teacher;
  final String category;
  final int materials;
  final double progress;
  final IconData icon;

  ClassItem({
    required this.title,
    required this.teacher,
    required this.category,
    required this.materials,
    required this.progress,
    required this.icon,
  });
}

class ModuleItem {
  final String title;
  final String type; // 'reading' | 'quiz'
  final bool isCompleted;
  final bool isLocked;

  ModuleItem({
    required this.title, 
    required this.type, 
    this.isCompleted = false, 
    this.isLocked = false
  });
}

class AssignmentItem {
  final String id;
  final String title;
  final String description;
  final String deadline;
  final bool isSubmitted;

  AssignmentItem({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    this.isSubmitted = false,
  });
}

class Student {
  final String id;
  final String name;
  final int xp;
  final double progress;
  final String lastActive;

  Student({required this.id, required this.name, required this.xp, required this.progress, required this.lastActive});
}

// --- AUTH WRAPPER ---
enum AuthState { login, register, authenticated }

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  AuthState _currentAuthState = AuthState.login;
  String _userRole = 'student'; 
  String _userName = 'Pengguna';

  void _completeAuth(String role, String name) {
    setState(() {
      _userRole = role;
      _userName = name;
      _currentAuthState = AuthState.authenticated;
    });
  }

  void _logout() {
    setState(() {
      _currentAuthState = AuthState.login;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentAuthState) {
      case AuthState.register:
        return RegisterScreen(
          onToggle: () => setState(() => _currentAuthState = AuthState.login),
          onRegister: (role, name) => _completeAuth(role, name),
        );
      case AuthState.login:
        return LoginScreen(
          onToggle: () => setState(() => _currentAuthState = AuthState.register),
          onLogin: (role) => _completeAuth(role, role == 'student' ? 'Ararya' : 'Pak Ahmad'),
        );
      case AuthState.authenticated:
        return MainScaffold(
          role: _userRole, 
          userName: _userName,
          onLogout: _logout,
        );
    }
  }
}

// --- SCREEN: LOGIN ---
class LoginScreen extends StatelessWidget {
  final VoidCallback onToggle;
  final Function(String) onLogin;

  const LoginScreen({super.key, required this.onToggle, required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBrand(),
              const SizedBox(height: 40),
              const _CustomTextField(label: "Email", icon: Icons.email_outlined),
              const SizedBox(height: 16),
              const _CustomTextField(label: "Kata Sandi", icon: Icons.lock_outline, isPassword: true),
              const SizedBox(height: 24),
              _authButton("Masuk", () => onLogin('student'), isPrimary: true),
              const SizedBox(height: 12),
              TextButton(
                onPressed: onToggle,
                child: const Text("Belum punya akun? Daftar sekarang", style: TextStyle(color: kPrimaryColor)),
              ),
              const SizedBox(height: 40),
              const Text("Atau masuk sebagai khusus demo:", style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _roleChip("Pelajar", () => onLogin('student')),
                  const SizedBox(width: 8),
                  _roleChip("Pengajar", () => onLogin('teacher')),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleChip(String label, VoidCallback onTap) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onPressed: onTap,
      backgroundColor: Colors.white10,
    );
  }
}

// --- SCREEN: REGISTER ---
class RegisterScreen extends StatefulWidget {
  final VoidCallback onToggle;
  final Function(String, String) onRegister;

  const RegisterScreen({super.key, required this.onToggle, required this.onRegister});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String selectedRole = 'student';
  final TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBrand(),
              const SizedBox(height: 32),
              _CustomTextField(label: "Nama Lengkap", icon: Icons.person_outline, controller: nameController),
              const SizedBox(height: 16),
              const _CustomTextField(label: "Email", icon: Icons.email_outlined),
              const SizedBox(height: 16),
              const _CustomTextField(label: "Kata Sandi", icon: Icons.lock_outline, isPassword: true),
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Pilih Peran:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _roleRadio("Pelajar", "student"),
                  _roleRadio("Pengajar", "teacher"),
                ],
              ),
              const SizedBox(height: 24),
              _authButton("Buat Akun", () => widget.onRegister(selectedRole, nameController.text.isEmpty ? 'Pengguna' : nameController.text), isPrimary: true),
              const SizedBox(height: 12),
              TextButton(
                onPressed: widget.onToggle,
                child: const Text("Sudah punya akun? Masuk", style: TextStyle(color: kPrimaryColor)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleRadio(String label, String value) {
    return Expanded(
      child: RadioListTile<String>(
        title: Text(label, style: const TextStyle(fontSize: 14)),
        value: value,
        groupValue: selectedRole,
        activeColor: kPrimaryColor,
        contentPadding: EdgeInsets.zero,
        onChanged: (v) => setState(() => selectedRole = v!),
      ),
    );
  }
}

// --- SHARED AUTH WIDGETS ---
Widget _buildBrand() {
  return Column(
    children: [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: kPrimaryColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(Icons.bolt_rounded, size: 50, color: Color(0xFF020617)),
      ),
      const SizedBox(height: 24),
      const Text(
        "EnerThink",
        style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: kPrimaryColor),
      ),
      const Text("Platform Edukasi Energi Terbarukan", style: TextStyle(color: Colors.grey, fontSize: 14)),
    ],
  );
}

Widget _authButton(String label, VoidCallback onTap, {bool isPrimary = false}) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? kPrimaryColor : Colors.transparent,
        foregroundColor: isPrimary ? Colors.black : kPrimaryColor,
        side: isPrimary ? null : const BorderSide(color: kPrimaryColor),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    ),
  );
}

class _CustomTextField extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPassword;
  final int maxLines;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const _CustomTextField({required this.label, required this.icon, this.isPassword = false, this.maxLines = 1, this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      onChanged: onChanged,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey, size: 20),
        filled: true,
        fillColor: const Color(0xFF0F172A),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: kPrimaryColor, width: 1)),
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      ),
    );
  }
}

// --- MAIN SCAFFOLD ---
class MainScaffold extends StatefulWidget {
  final String role;
  final String userName;
  final VoidCallback onLogout;
  const MainScaffold({super.key, required this.role, required this.userName, required this.onLogout});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  
  // State List untuk Kelas
  List<ClassItem> myClasses = [
    ClassItem(title: "Energi Angin 101", teacher: "Indah Bayu", category: "WIND", materials: 6, progress: 0, icon: Icons.air_rounded),
    ClassItem(title: "Geothermal Modern", teacher: "Dr. Budi", category: "THERMAL", materials: 10, progress: 0, icon: Icons.whatshot_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final List<Widget> views = [
      HomeView(role: widget.role, name: widget.userName, classes: myClasses),
      ClassCatalogView(classes: myClasses, role: widget.role),
      ProfileView(name: widget.userName, onLogout: widget.onLogout),
    ];

    return Scaffold(
      body: SafeArea(child: views[_currentIndex]),
      floatingActionButton: widget.role == 'teacher' && _currentIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () => _showAddClassModal(context),
              icon: const Icon(Icons.add, color: Colors.black),
              label: const Text("Buat Kelas", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              backgroundColor: kPrimaryColor,
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        backgroundColor: const Color(0xFF0F172A),
        indicatorColor: kPrimaryColor.withOpacity(0.2),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: kPrimaryColor), label: 'Beranda'),
          NavigationDestination(icon: Icon(Icons.search), selectedIcon: Icon(Icons.manage_search, color: kPrimaryColor), label: 'Kelas'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: kPrimaryColor), label: 'Profil'),
        ],
      ),
    );
  }

  void _showAddClassModal(BuildContext context) {
    final titleController = TextEditingController();
    final categoryController = TextEditingController();
    final materialsController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Buat Kelas Energi Baru", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _CustomTextField(label: "Judul Kelas", icon: Icons.title, controller: titleController),
            const SizedBox(height: 16),
            _CustomTextField(label: "Kategori (Panel Surya/Angin/dll)", icon: Icons.category_outlined, controller: categoryController),
            const SizedBox(height: 16),
            _CustomTextField(label: "Jumlah Modul Awal", icon: Icons.format_list_numbered, controller: materialsController),
            const SizedBox(height: 32),
            _authButton("Publikasikan Kelas", () {
              if (titleController.text.isNotEmpty) {
                setState(() {
                  myClasses.add(ClassItem(
                    title: titleController.text,
                    teacher: widget.userName,
                    category: categoryController.text.toUpperCase(),
                    materials: int.tryParse(materialsController.text) ?? 5,
                    progress: 0,
                    icon: Icons.science_rounded,
                  ));
                });
                Navigator.pop(context);
              }
            }, isPrimary: true),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// --- VIEW: HOME ---
class HomeView extends StatelessWidget {
  final String role;
  final String name;
  final List<ClassItem> classes;
  const HomeView({super.key, required this.role, required this.name, required this.classes});

  @override
  Widget build(BuildContext context) {
    final continueClass = ClassItem(
      title: "Dasar Panel Surya",
      teacher: "Dr. Surya",
      category: "SOLAR",
      materials: 8,
      progress: 0.45,
      icon: Icons.wb_sunny_rounded,
    );

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Selamat pagi,", style: TextStyle(color: Colors.grey)),
                Text("$name 👋", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
            _xpBadge(),
          ],
        ),
        const SizedBox(height: 24),
        
        // --- PERFORMANCE STATS (NEW FOR STUDENT) ---
        if (role == 'student') ...[
          _buildPerformanceRow(context),
          const SizedBox(height: 32),
          _sectionHeader("Lanjutkan Belajar", Icons.play_arrow_rounded),
          const SizedBox(height: 16),
          _buildContinueCard(context, continueClass),
          const SizedBox(height: 32),
          _sectionHeader("Kelas Terdaftar", Icons.library_books_rounded),
        ] else ...[
          _buildTeacherStats(),
          const SizedBox(height: 32),
          _sectionHeader("Ringkasan Kelas", Icons.dashboard_rounded),
        ],
        const SizedBox(height: 16),
        _buildClassList(context, classes, role),
      ],
    );
  }

  Widget _buildPerformanceRow(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _performanceCard("7 Hari", "Streak Harian", Icons.local_fire_department_rounded, Colors.orange),
          const SizedBox(width: 12),
          _performanceCard("#12", "Papan Peringkat", Icons.leaderboard_rounded, kPrimaryColor, onTap: () {
             Navigator.push(context, MaterialPageRoute(builder: (c) => const LeaderboardView()));
          }),
          const SizedBox(width: 12),
          _performanceCard("5", "Lencana", Icons.military_tech_rounded, Colors.blueAccent),
        ],
      ),
    );
  }

  Widget _performanceCard(String val, String label, IconData icon, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(val, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _xpBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16)),
      child: const Row(
        children: [
          Icon(Icons.bolt, color: kPrimaryColor, size: 20),
          SizedBox(width: 4),
          Text("1.250 XP", style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: kPrimaryColor, size: 20),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildContinueCard(BuildContext context, ClassItem item) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => ClassDetailView(item: item, role: role))),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(color: kPrimaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
              child: Icon(item.icon, color: kPrimaryColor, size: 40),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Text("Level 2: Instalasi", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(value: item.progress, backgroundColor: Colors.white10, borderRadius: BorderRadius.circular(10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeacherStats() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _statCard("Siswa Aktif", "1.240", Icons.people, Colors.blue),
        _statCard("Tingkat Lulus", "92%", Icons.verified, kPrimaryColor),
      ],
    );
  }

  Widget _statCard(String label, String val, IconData icon, Color col) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: col),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              Text(val, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildClassList(BuildContext context, List<ClassItem> list, String userRole) {
    return Column(
      children: list.map((c) => ListTile(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => ClassDetailView(item: c, role: userRole))),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50, height: 50,
          decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
          child: Icon(c.icon, color: kPrimaryColor),
        ),
        title: Text(c.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${c.materials} Materi • ${c.teacher}"),
        trailing: const Icon(Icons.chevron_right),
      )).toList(),
    );
  }
}

// --- VIEW: STUDENT MANAGEMENT (INTERACTIVE) ---
class StudentManagementView extends StatefulWidget {
  final String className;
  const StudentManagementView({super.key, required this.className});

  @override
  State<StudentManagementView> createState() => _StudentManagementViewState();
}

class _StudentManagementViewState extends State<StudentManagementView> {
  late List<Student> students;
  late List<Student> filteredStudents;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Inisialisasi data simulasi
    students = [
      Student(id: "1", name: "Ararya", xp: 1250, progress: 0.85, lastActive: "2 Menit Lalu"),
      Student(id: "2", name: "Budi Cahyo", xp: 980, progress: 0.60, lastActive: "1 Jam Lalu"),
      Student(id: "3", name: "Siti Aminah", xp: 1500, progress: 0.95, lastActive: "Sekarang"),
      Student(id: "4", name: "Dedi Setiawan", xp: 450, progress: 0.20, lastActive: "Kemarin"),
      Student(id: "5", name: "Eka Putri", xp: 720, progress: 0.40, lastActive: "3 Jam Lalu"),
    ];
    filteredStudents = List.from(students);
  }

  void _filterStudents(String query) {
    setState(() {
      filteredStudents = students
          .where((s) => s.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _removeStudent(Student student) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text("Hapus Siswa"),
        content: Text("Apakah Anda yakin ingin menghapus ${student.name} dari kelas ini?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal", style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              setState(() {
                students.removeWhere((s) => s.id == student.id);
                _filterStudents(searchController.text);
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("${student.name} telah dihapus."), backgroundColor: Colors.redAccent),
              );
            }, 
            child: const Text("Hapus", style: TextStyle(color: Colors.redAccent))
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Manajemen Siswa: ${widget.className}"), backgroundColor: Colors.transparent),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: _CustomTextField(
              label: "Cari nama siswa...",
              icon: Icons.search,
              controller: searchController,
              onChanged: _filterStudents,
            ),
          ),
          Expanded(
            child: filteredStudents.isEmpty 
              ? const Center(child: Text("Siswa tidak ditemukan.", style: TextStyle(color: Colors.grey)))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: filteredStudents.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final s = filteredStudents[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
                      child: Row(
                        children: [
                          CircleAvatar(backgroundColor: kPrimaryColor.withOpacity(0.1), child: Text(s.name[0], style: const TextStyle(color: kPrimaryColor))),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text("Aktif: ${s.lastActive}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(value: s.progress, backgroundColor: Colors.white10, borderRadius: BorderRadius.circular(10), minHeight: 6),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("${s.xp} XP", style: const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                              IconButton(
                                icon: const Icon(Icons.person_remove_outlined, size: 20, color: Colors.redAccent),
                                onPressed: () => _removeStudent(s),
                              )
                            ],
                          )
                        ],
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
}

// --- VIEW: CLASS CATALOG ---
class ClassCatalogView extends StatelessWidget {
  final List<ClassItem> classes;
  final String role;
  const ClassCatalogView({super.key, required this.classes, required this.role});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Katalog Kelas", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
              hintText: "Cari materi energi...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: const Color(0xFF0F172A),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: classes.length,
              itemBuilder: (context, index) => _catalogItem(context, classes[index]),
            ),
          )
        ],
      ),
    );
  }

  Widget _catalogItem(BuildContext context, ClassItem item) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => ClassDetailView(item: item, role: role))),
      child: Container(
        decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                child: Icon(item.icon, color: kPrimaryColor.withOpacity(0.5), size: 40),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("KATEGORI", style: TextStyle(color: kPrimaryColor, fontSize: 10, fontWeight: FontWeight.bold)),
                  Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text("${item.materials} Modul", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// --- VIEW: CLASS DETAIL ---
class ClassDetailView extends StatefulWidget {
  final ClassItem item;
  final String role;
  const ClassDetailView({super.key, required this.item, required this.role});

  @override
  State<ClassDetailView> createState() => _ClassDetailViewState();
}

class _ClassDetailViewState extends State<ClassDetailView> {
  late List<AssignmentItem> assignments;

  @override
  void initState() {
    super.initState();
    assignments = [
      AssignmentItem(id: "A1", title: "Analisis Dampak Lingkungan", description: "Buatlah esai mengenai dampak pembangunan PLTS di lingkungan perumahan.", deadline: "25 Jan 2026"),
    ];
  }

  void _showAddAssignmentModal() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final deadlineController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Buat Tugas Baru", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _CustomTextField(label: "Judul Tugas", icon: Icons.assignment_outlined, controller: titleController),
            const SizedBox(height: 16),
            _CustomTextField(label: "Instruksi Tugas", icon: Icons.description_outlined, controller: descController, maxLines: 3),
            const SizedBox(height: 16),
            _CustomTextField(label: "Tenggat Waktu (e.g., 30 Jan 2026)", icon: Icons.calendar_today_outlined, controller: deadlineController),
            const SizedBox(height: 32),
            _authButton("Berikan Tugas", () {
              if (titleController.text.isNotEmpty) {
                setState(() {
                  assignments.add(AssignmentItem(
                    id: DateTime.now().toString(),
                    title: titleController.text,
                    description: descController.text,
                    deadline: deadlineController.text,
                  ));
                });
                Navigator.pop(context);
              }
            }, isPrimary: true),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final modules = [
      ModuleItem(title: "Perkenalan Konsep", type: "reading", isCompleted: true),
      ModuleItem(title: "Level 1: Dasar Teori", type: "reading", isCompleted: true),
      ModuleItem(title: "Level 2: Implementasi", type: "reading"),
      ModuleItem(title: "Kuis Akhir", type: "quiz", isLocked: false),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.title), 
        backgroundColor: Colors.transparent, 
        elevation: 0,
        actions: [
          if (widget.role == 'teacher')
            IconButton(
              icon: const Icon(Icons.people_outline, color: kPrimaryColor),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => StudentManagementView(className: widget.item.title))),
              tooltip: "Manajemen Siswa",
            )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            height: 160,
            decoration: BoxDecoration(color: kPrimaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(24)),
            child: Icon(widget.item.icon, size: 80, color: kPrimaryColor),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Kurikulum & Tugas", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              if (widget.role == 'teacher')
                 const Badge(label: Text("Mode Edit"), backgroundColor: Colors.white10),
            ],
          ),
          const SizedBox(height: 16),
          // MODUL SECTION
          ...modules.map((m) => _moduleTile(context, m)).toList(),
          
          const SizedBox(height: 24),
          const Text("Daftar Tugas", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kPrimaryColor)),
          const SizedBox(height: 8),
          // ASSIGNMENT SECTION
          ...assignments.map((a) => _assignmentTile(context, a)).toList(),

          if (widget.role == 'teacher')
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Column(
                children: [
                  OutlinedButton.icon(
                    onPressed: _showAddAssignmentModal,
                    icon: const Icon(Icons.add_task),
                    label: const Text("Tambah Tugas Baru"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kPrimaryColor,
                      side: const BorderSide(color: kPrimaryColor),
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                    label: const Text("Tambah Materi Baru"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey,
                      side: const BorderSide(color: Colors.white24),
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }

  Widget _moduleTile(BuildContext context, ModuleItem m) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () {
          if (m.type == 'quiz') {
            Navigator.push(context, MaterialPageRoute(builder: (c) => const QuizView()));
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (c) => MaterialContentView(title: m.title)));
          }
        },
        tileColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Icon(
          m.isCompleted ? Icons.check_circle : (m.type == 'quiz' ? Icons.emoji_events : Icons.menu_book),
          color: m.isCompleted ? kPrimaryColor : Colors.grey,
        ),
        title: Text(m.title, style: TextStyle(color: m.isLocked ? Colors.grey : Colors.white)),
        trailing: Icon(m.isLocked ? Icons.lock : Icons.play_arrow_rounded, size: 18),
      ),
    );
  }

  Widget _assignmentTile(BuildContext context, AssignmentItem a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kPrimaryColor.withOpacity(0.2)),
      ),
      child: ListTile(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => AssignmentDetailView(assignment: a, role: widget.role))),
        leading: const CircleAvatar(backgroundColor: Colors.white10, child: Icon(Icons.assignment, size: 20, color: kPrimaryColor)),
        title: Text(a.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Deadline: ${a.deadline}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: widget.role == 'teacher' 
          ? const Icon(Icons.analytics_outlined, color: kPrimaryColor)
          : (a.isSubmitted ? const Icon(Icons.check_circle, color: kPrimaryColor) : const Icon(Icons.upload_file, color: Colors.grey)),
      ),
    );
  }
}

// --- VIEW: ASSIGNMENT DETAIL ---
class AssignmentDetailView extends StatelessWidget {
  final AssignmentItem assignment;
  final String role;
  const AssignmentDetailView({super.key, required this.assignment, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Tugas")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.assignment, color: kPrimaryColor, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(assignment.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      Text("Deadline: ${assignment.deadline}", style: const TextStyle(color: Colors.redAccent, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 48, color: Colors.white10),
            const Text("Instruksi Tugas:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              assignment.description,
              style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.white70),
            ),
            const SizedBox(height: 48),
            if (role == 'student')
              _authButton(
                assignment.isSubmitted ? "Tugas Telah Dikirim" : "Kirim Tugas", 
                () => Navigator.push(context, MaterialPageRoute(builder: (c) => SubmissionFormView(assignment: assignment))),
                isPrimary: !assignment.isSubmitted
              )
            else
              _authButton(
                "Lihat Pengumpulan Siswa", 
                () => Navigator.push(context, MaterialPageRoute(builder: (c) => TeacherSubmissionsView(assignment: assignment))),
                isPrimary: true
              ),
          ],
        ),
      ),
    );
  }
}

// --- VIEW: SUBMISSION FORM (STUDENT) ---
class SubmissionFormView extends StatelessWidget {
  final AssignmentItem assignment;
  const SubmissionFormView({super.key, required this.assignment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kirim Tugas")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Mengirim untuk: ${assignment.title}", style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            const _CustomTextField(label: "Tautan Tugas (Google Drive/PDF)", icon: Icons.link),
            const SizedBox(height: 16),
            const _CustomTextField(label: "Catatan Tambahan", icon: Icons.note_add_outlined, maxLines: 4),
            const Spacer(),
            _authButton("Kirim Sekarang", () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Tugas berhasil dikirim!"), backgroundColor: kPrimaryColor),
              );
            }, isPrimary: true),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// --- VIEW: TEACHER SUBMISSIONS VIEW ---
class TeacherSubmissionsView extends StatelessWidget {
  final AssignmentItem assignment;
  const TeacherSubmissionsView({super.key, required this.assignment});

  @override
  Widget build(BuildContext context) {
    final submissions = [
      {"name": "Ararya", "time": "20 Jan, 14:00", "status": "Dinilai"},
      {"name": "Siti Aminah", "time": "21 Jan, 09:15", "status": "Belum Dinilai"},
      {"name": "Budi Cahyo", "time": "21 Jan, 10:00", "status": "Belum Dinilai"},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Pengumpulan Siswa")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text("Tugas: ${assignment.title}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kPrimaryColor)),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: submissions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final sub = submissions[index];
                return ListTile(
                  tileColor: const Color(0xFF0F172A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(sub['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Dikirim: ${sub['time']}"),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: sub['status'] == 'Dinilai' ? kPrimaryColor.withOpacity(0.1) : Colors.white10,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(sub['status']!, style: TextStyle(fontSize: 10, color: sub['status'] == 'Dinilai' ? kPrimaryColor : Colors.grey)),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

// --- VIEW: LEADERBOARD (NEW) ---
class LeaderboardView extends StatelessWidget {
  const LeaderboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final leaderboard = [
      {"name": "Siti Aminah", "xp": 4500, "rank": 1},
      {"name": "Budi Cahyo", "xp": 3800, "rank": 2},
      {"name": "Eka Putri", "xp": 3200, "rank": 3},
      {"name": "Ararya", "xp": 1250, "rank": 12},
      {"name": "Dedi Setiawan", "xp": 900, "rank": 13},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Papan Peringkat")),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                 _podiumItem("Budi", "2", 32, Colors.grey),
                 _podiumItem("Siti", "1", 48, Colors.amber),
                 _podiumItem("Eka", "3", 32, Colors.orangeAccent),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: leaderboard.length,
              itemBuilder: (context, index) {
                final user = leaderboard[index];
                final isMe = user['name'] == "Ararya";
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isMe ? kPrimaryColor.withOpacity(0.1) : const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isMe ? kPrimaryColor : Colors.white10),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 30,
                        child: Text("${user['rank']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      ),
                      const CircleAvatar(backgroundColor: Colors.white10, child: Icon(Icons.person, size: 20)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          "${user['name']} ${isMe ? '(Anda)' : ''}", 
                          style: TextStyle(fontWeight: isMe ? FontWeight.bold : FontWeight.normal)
                        ),
                      ),
                      Text("${user['xp']} XP", style: const TextStyle(fontWeight: FontWeight.bold, color: kPrimaryColor)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _podiumItem(String name, String rank, double radius, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: color,
          child: Text(rank, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24)),
        ),
        const SizedBox(height: 8),
        Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// --- VIEW: MATERIAL CONTENT ---
class MaterialContentView extends StatelessWidget {
  final String title;
  const MaterialContentView({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Materi Pembelajaran",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kPrimaryColor),
            ),
            const SizedBox(height: 16),
            Text(
              "Energi terbarukan adalah energi yang berasal dari proses alam yang berkelanjutan. Dalam modul $title ini, kita akan mempelajari bagaimana teknologi modern dapat menangkap energi ini tanpa merusak ekosistem sekitar. \n\n"
              "Fokus utama kita adalah efisiensi dan adaptabilitas sistem terhadap perubahan lingkungan.",
              style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.white70),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor, foregroundColor: Colors.black, padding: const EdgeInsets.all(16)),
                child: const Text("Selesaikan Materi", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// --- VIEW: QUIZ INTERACTIVE ---
class QuizView extends StatefulWidget {
  const QuizView({super.key});

  @override
  State<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  int currentQuestion = 0;
  final List<Map<String, dynamic>> questions = [
    {
      "q": "Apa komponen utama panel surya?",
      "o": ["Silikon", "Baja", "Plastik", "Kayu"],
      "a": 0
    },
    {
      "q": "Energi yang dihasilkan panas bumi disebut?",
      "o": ["Solar", "Hydro", "Geothermal", "Wind"],
      "a": 2
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kuis Energi")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(value: (currentQuestion + 1) / questions.length),
            const SizedBox(height: 32),
            Text("Pertanyaan ${currentQuestion + 1}/${questions.length}", style: const TextStyle(color: kPrimaryColor)),
            const SizedBox(height: 8),
            Text(questions[currentQuestion]['q'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            ...List.generate(4, (index) => _answerOption(index)),
          ],
        ),
      ),
    );
  }

  Widget _answerOption(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          if (currentQuestion < questions.length - 1) {
            setState(() => currentQuestion++);
          } else {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const QuizResultView()));
          }
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
          child: Row(
            children: [
              CircleAvatar(radius: 12, backgroundColor: Colors.white10, child: Text("${String.fromCharCode(65 + index)}", style: const TextStyle(fontSize: 10))),
              const SizedBox(width: 16),
              Text(questions[currentQuestion]['o'][index]),
            ],
          ),
        ),
      ),
    );
  }
}

// --- VIEW: QUIZ RESULT ---
class QuizResultView extends StatelessWidget {
  const QuizResultView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.stars_rounded, size: 100, color: Colors.amber),
              const SizedBox(height: 24),
              const Text("Luar Biasa!", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const Text("Kamu menyelesaikan kuis dengan skor sempurna", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(24)),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ResultStat(label: "Skor", val: "100"),
                    _ResultStat(label: "XP", val: "+250"),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor, foregroundColor: Colors.black, padding: const EdgeInsets.all(16)),
                  child: const Text("Selesai & Kembali", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  final String label;
  final String val;
  const _ResultStat({required this.label, required this.val});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(val, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kPrimaryColor)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}

// --- VIEW: PROFILE ---
class ProfileView extends StatelessWidget {
  final String name;
  final VoidCallback onLogout;
  const ProfileView({super.key, required this.name, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Center(
          child: Column(
            children: [
              const CircleAvatar(radius: 50, backgroundColor: kPrimaryColor, child: Icon(Icons.person, size: 50, color: Colors.black)),
              const SizedBox(height: 16),
              Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Text("Level 5", style: TextStyle(color: kPrimaryColor)),
            ],
          ),
        ),
        const SizedBox(height: 40),
        _profileMenu(
          context, 
          Icons.settings, 
          "Pengaturan Akun", 
          () => Navigator.push(context, MaterialPageRoute(builder: (c) => const SettingsView()))
        ),
        _profileMenu(
          context, 
          Icons.bar_chart, 
          "Hasil Pembelajaran", 
          () => Navigator.push(context, MaterialPageRoute(builder: (c) => const LearningOutcomesView()))
        ),
        _profileMenu(
          context, 
          Icons.info_outline, 
          "Tentang EnerThink", 
          () => Navigator.push(context, MaterialPageRoute(builder: (c) => const AboutView()))
        ),
        const SizedBox(height: 24),
        ListTile(
          onTap: onLogout,
          leading: const Icon(Icons.logout, color: Colors.redAccent),
          title: const Text("Keluar Akun", style: TextStyle(color: Colors.redAccent)),
        )
      ],
    );
  }

  Widget _profileMenu(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, size: 18),
      onTap: onTap,
    );
  }
}

// --- VIEW: SETTINGS ---
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pengaturan Akun")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Center(
              child: Stack(
                children: [
                  CircleAvatar(radius: 50, backgroundColor: Colors.white10, child: Icon(Icons.person, size: 50)),
                  Positioned(bottom: 0, right: 0, child: CircleAvatar(radius: 15, backgroundColor: kPrimaryColor, child: Icon(Icons.camera_alt, size: 15, color: Colors.black))),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const _CustomTextField(label: "Nama Lengkap", icon: Icons.person_outline),
            const SizedBox(height: 16),
            const _CustomTextField(label: "Email", icon: Icons.email_outlined),
            const SizedBox(height: 16),
            const _CustomTextField(label: "Kata Sandi Baru", icon: Icons.lock_outline, isPassword: true),
            const SizedBox(height: 32),
            _authButton("Simpan Perubahan", () => Navigator.pop(context), isPrimary: true),
          ],
        ),
      ),
    );
  }
}

// --- VIEW: LEARNING OUTCOMES ---
class LearningOutcomesView extends StatelessWidget {
  const LearningOutcomesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hasil Pembelajaran")),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _resultCard("Dasar Panel Surya", "Selesai", "95/100", Icons.wb_sunny),
          _resultCard("Energi Angin 101", "Dalam Progres", "45/100", Icons.air),
          _resultCard("Kuis Pengantar", "Selesai", "100/100", Icons.emoji_events),
        ],
      ),
    );
  }

  Widget _resultCard(String title, String status, String score, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
      child: Row(
        children: [
          Icon(icon, color: kPrimaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(status, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Text(score, style: const TextStyle(fontWeight: FontWeight.bold, color: kPrimaryColor)),
        ],
      ),
    );
  }
}

// --- VIEW: ABOUT ---
class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tentang EnerThink")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: kPrimaryColor, borderRadius: BorderRadius.circular(24)),
              child: const Icon(Icons.bolt_rounded, size: 60, color: Color(0xFF020617)),
            ),
            const SizedBox(height: 24),
            const Text("EnerThink", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: kPrimaryColor)),
            const Text("Versi 1.0.0", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            const Text(
              "EnerThink adalah platform pembelajaran berbasis gamifikasi yang dirancang untuk mengedukasi masyarakat tentang pentingnya energi terbarukan dan keberlanjutan. \n\n"
              "Misi kami adalah menciptakan generasi yang sadar akan lingkungan melalui pengalaman belajar yang interaktif and adaptif.",
              textAlign: TextAlign.center,
              style: TextStyle(height: 1.6, color: Colors.white70),
            ),
            const Spacer(),
            const Text("Dibuat dengan ❤️ untuk Masa Depan Hijau", style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}