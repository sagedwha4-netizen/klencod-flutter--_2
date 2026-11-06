import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const UniversityApp());
}

class UniversityApp extends StatelessWidget {
  const UniversityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'جامعتي',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF176B87)),
        scaffoldBackgroundColor: const Color(0xFFF4F7FA),
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedIndex = 0;
  bool loading = true;

  List<Map<String, dynamic>> subjects = [];
  List<Map<String, dynamic>> tasks = [];
  List<Map<String, dynamic>> grades = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      subjects = _readList(prefs, 'subjects');
      tasks = _readList(prefs, 'tasks');
      grades = _readList(prefs, 'grades');
      loading = false;
    });
  }

  List<Map<String, dynamic>> _readList(
      SharedPreferences prefs, String key) {
    final raw = prefs.getString(key);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw) as List;
      return decoded
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('subjects', jsonEncode(subjects));
    await prefs.setString('tasks', jsonEncode(tasks));
    await prefs.setString('grades', jsonEncode(grades));
  }

  void addSubject() {
    final name = TextEditingController();
    final day = TextEditingController();
    final time = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('إضافة محاضرة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'اسم المادة')),
            TextField(controller: day, decoration: const InputDecoration(labelText: 'اليوم')),
            TextField(controller: time, decoration: const InputDecoration(labelText: 'الوقت')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () async {
              if (name.text.trim().isEmpty) return;
              setState(() => subjects.add({
                    'name': name.text.trim(),
                    'day': day.text.trim(),
                    'time': time.text.trim(),
                  }));
              await saveData();
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void addTask() {
    final name = TextEditingController();
    final date = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('إضافة واجب أو مهمة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'اسم المهمة')),
            TextField(controller: date, decoration: const InputDecoration(labelText: 'موعد التسليم')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () async {
              if (name.text.trim().isEmpty) return;
              setState(() => tasks.add({
                    'name': name.text.trim(),
                    'date': date.text.trim(),
                    'done': false,
                  }));
              await saveData();
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void addGrade() {
    final subject = TextEditingController();
    final grade = TextEditingController();
    final total = TextEditingController(text: '100');

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('إضافة درجة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: subject, decoration: const InputDecoration(labelText: 'اسم المادة')),
            TextField(
              controller: grade,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'درجتك'),
            ),
            TextField(
              controller: total,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'الدرجة الكاملة'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () async {
              final value = double.tryParse(grade.text.trim());
              final max = double.tryParse(total.text.trim());
              if (subject.text.trim().isEmpty ||
                  value == null ||
                  max == null ||
                  max <= 0 ||
                  value < 0 ||
                  value > max) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تحقق من اسم المادة والدرجات المدخلة')),
                );
                return;
              }
              setState(() => grades.add({
                    'subject': subject.text.trim(),
                    'grade': value,
                    'total': max,
                  }));
              await saveData();
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('حفظ الدرجة'),
          ),
        ],
      ),
    );
  }

  Future<void> deleteItem(List<Map<String, dynamic>> list, int index) async {
    setState(() => list.removeAt(index));
    await saveData();
  }

  Future<void> toggleTask(int index, bool? value) async {
    setState(() => tasks[index]['done'] = value ?? false);
    await saveData();
  }

  double get average {
    if (grades.isEmpty) return 0;
    final percentages = grades.map((item) {
      final score = (item['grade'] as num).toDouble();
      final max = (item['total'] as num).toDouble();
      return score / max * 100;
    });
    return percentages.reduce((a, b) => a + b) / grades.length;
  }

  @override
  Widget build(BuildContext context) {
    final pages = [homePage(), subjectsPage(), tasksPage(), gradesPage()];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('جامعتي', style: TextStyle(fontWeight: FontWeight.bold)),
          actions: const [
            Padding(
              padding: EdgeInsets.all(12),
              child: Icon(Icons.school, color: Color(0xFF176B87)),
            ),
          ],
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : pages[selectedIndex],
        floatingActionButton: selectedIndex == 1
            ? FloatingActionButton(onPressed: addSubject, child: const Icon(Icons.add))
            : selectedIndex == 2
                ? FloatingActionButton(onPressed: addTask, child: const Icon(Icons.add))
                : selectedIndex == 3
                    ? FloatingActionButton(onPressed: addGrade, child: const Icon(Icons.add))
                    : null,
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) => setState(() => selectedIndex = index),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'الرئيسية'),
            NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'المحاضرات'),
            NavigationDestination(icon: Icon(Icons.task_alt_outlined), selectedIcon: Icon(Icons.task_alt), label: 'المهام'),
            NavigationDestination(icon: Icon(Icons.grade_outlined), selectedIcon: Icon(Icons.grade), label: 'الدرجات'),
          ],
        ),
      ),
    );
  }

  Widget homePage() {
    final completed = tasks.where((task) => task['done'] == true).length;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF176B87), Color(0xFF064663)]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('مرحباً بك في تطبيق جامعتي 👋',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text('نظّم دراستك، وتابع مهامك، وحقق أهدافك.',
                  style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const Text('ملخص دراستك', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            summaryCard('المحاضرات', '${subjects.length}', Icons.menu_book, Colors.blue),
            summaryCard('المهام', '${tasks.length}', Icons.assignment, Colors.orange),
            summaryCard('المكتملة', '$completed', Icons.check_circle, Colors.green),
            summaryCard('المعدل', '${average.toStringAsFixed(1)}%', Icons.grade, Colors.purple),
          ],
        ),
        const SizedBox(height: 22),
        const Text('آخر المهام', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        if (tasks.isEmpty)
          emptyMessage('لا توجد مهام حتى الآن')
        else
          ...tasks.take(3).map((task) => Card(
                child: ListTile(
                  leading: const Icon(Icons.assignment_outlined),
                  title: Text(task['name'] as String),
                  subtitle: Text((task['date'] ?? '') as String),
                  trailing: Icon(
                    task['done'] == true ? Icons.check_circle : Icons.pending_actions,
                    color: task['done'] == true ? Colors.green : Colors.orange,
                  ),
                ),
              )),
      ],
    );
  }

  Widget summaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(icon, color: color, size: 27),
          Text(value, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget subjectsPage() {
    if (subjects.isEmpty) return emptyMessage('لم تضف أي محاضرات بعد');
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final item = subjects[index];
        return Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.book)),
            title: Text(item['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${item['day']} - ${item['time']}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => deleteItem(subjects, index),
            ),
          ),
        );
      },
    );
  }

  Widget tasksPage() {
    if (tasks.isEmpty) return emptyMessage('لا توجد مهام. اضغط + لإضافة مهمة');
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final item = tasks[index];
        return Card(
          child: CheckboxListTile(
            value: item['done'] == true,
            onChanged: (value) => toggleTask(index, value),
            title: Text(
              item['name'] as String,
              style: TextStyle(
                decoration: item['done'] == true ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Text((item['date'] ?? '') as String),
            secondary: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => deleteItem(tasks, index),
            ),
          ),
        );
      },
    );
  }

  Widget gradesPage() {
    if (grades.isEmpty) return emptyMessage('لم تسجل أي درجات بعد');
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Card(
          color: const Color(0xFFDDF1F6),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text('متوسط درجاتك'),
                const SizedBox(height: 8),
                Text('${average.toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF176B87))),
              ],
            ),
          ),
        ),
        ...List.generate(grades.length, (index) {
          final item = grades[index];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.school),
              title: Text(item['subject'] as String),
              subtitle: Text('${item['grade']} من ${item['total']}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => deleteItem(grades, index),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget emptyMessage(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox_outlined, size: 65, color: Colors.grey),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}