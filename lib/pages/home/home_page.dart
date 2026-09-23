import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/weather_model.dart';
import '../../providers/announcement_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/maintenance_provider.dart';
import '../../services/weather_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/announcement_card.dart';
import '../../widgets/weather_card.dart';
import '../announcement/announcement_detail_page.dart';
import '../bills/electricity_calculator_page.dart';
import '../maintenance/create_maintenance_page.dart';

/// HomePage เป็น StatefulWidget เพื่อสาธิต Life Cycle ตาม Lecture 7:
/// - initState(): เรียก API สภาพอากาศทันทีที่หน้าจอถูกสร้าง (เหมาะกับการ Fetch Data)
/// - dispose(): ยกเลิก mounted-guard เพื่อป้องกัน setState หลังหน้าจอถูกทำลาย
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final WeatherService _weatherService = WeatherService();

  WeatherModel? _weather;
  bool _weatherLoading = true;
  String? _weatherError;

  @override
  void initState() {
    super.initState();
    _fetchWeather();

    // เริ่มฟังข้อมูลประกาศและคำขอแจ้งซ่อมแบบเรียลไทม์จาก Firestore ผ่าน Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      context.read<AnnouncementProvider>().start();
      if (auth.userProfile != null) {
        if (auth.isAdmin) {
          context.read<MaintenanceProvider>().startForAdmin();
        } else {
          context.read<MaintenanceProvider>().startForUser(auth.userProfile!.uid);
        }
      }
    });
  }

  Future<void> _fetchWeather() async {
    setState(() {
      _weatherLoading = true;
      _weatherError = null;
    });
    try {
      final weather = await _weatherService.fetchCurrentWeather();
      if (!mounted) return; // ป้องกัน setState หลัง widget ถูก dispose (Lecture 9)
      setState(() {
        _weather = weather;
        _weatherLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _weatherError = e.toString();
        _weatherLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // ตัวอย่าง dispose(): จุดสำหรับยกเลิก listener/controller ถ้ามีการสร้างไว้
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.userProfile;
    final announcementProvider = context.watch<AnnouncementProvider>();
    final maintenanceProvider = context.watch<MaintenanceProvider>();

    final pinned = announcementProvider.announcements.where((a) => a.pinned).toList();
    final latest = pinned.isNotEmpty
        ? pinned.first
        : (announcementProvider.announcements.isNotEmpty
            ? announcementProvider.announcements.first
            : null);

    final openRequests =
        maintenanceProvider.requests.where((r) => r.status.name != 'done').length;

    return Scaffold(
      appBar: AppBar(
        title: Text('สวัสดี, ${user?.name.split(' ').first ?? ''} 👋'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _fetchWeather();
          announcementProvider.start();
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (user != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppSpacing.radius),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.primaryLight,
                      child: Text(
                        user.name.isNotEmpty ? user.name.substring(0, 1) : '?',
                        style: const TextStyle(
                            color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 20),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                          Text('ห้อง ${user.room}', style: const TextStyle(color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                    if (user.isAdmin)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.accentLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('ผู้ดูแล',
                            style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700, fontSize: 12)),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            WeatherCard(
              weather: _weather,
              isLoading: _weatherLoading,
              errorMessage: _weatherError,
              onRetry: _fetchWeather,
            ),
            const SizedBox(height: 20),
            const Text('เมนูด่วน', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    icon: Icons.bolt,
                    label: 'คำนวณค่าไฟ',
                    color: AppColors.accent,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ElectricityCalculatorPage()),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.build,
                    label: 'แจ้งซ่อม',
                    color: AppColors.primary,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CreateMaintenancePage()),
                    ),
                    badge: openRequests > 0 ? openRequests.toString() : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('ประกาศล่าสุด', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                if (latest != null)
                  TextButton(
                    onPressed: () {},
                    child: const Text('ดูทั้งหมด'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (announcementProvider.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (latest == null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppSpacing.radius),
                ),
                child: const Center(
                  child: Text('ยังไม่มีประกาศจากหอพัก', style: TextStyle(color: AppColors.textMuted)),
                ),
              )
            else
              AnnouncementCard(
                announcement: latest,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => AnnouncementDetailPage(announcement: latest)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final String? badge;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.radius),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
        ),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
                  child: Icon(icon, color: color),
                ),
                if (badge != null)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle),
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Text(
                        badge!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
