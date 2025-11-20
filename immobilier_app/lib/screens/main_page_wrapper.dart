import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/auth_service.dart';
import '../providers/theme_provider.dart';
import '../services/fcm_service.dart';
import '../screens/home/home_page.dart';
import '../screens/search/search_page.dart';
import '../screens/add_property/add_property_page.dart';
import '../screens/favorites/favorites_page.dart';
import '../screens/profile/profile_page.dart';
import '../screens/chat/chat_page.dart';

class MainPageWrapper extends StatefulWidget {
  const MainPageWrapper({super.key});

  @override
  State<MainPageWrapper> createState() => _MainPageWrapperState();
}

class _MainPageWrapperState extends State<MainPageWrapper> {
  int _selectedIndex = 0;
  bool _notificationsEnabled = true; // Default to enabled

  final List<Widget> _pages = const [
    HomePage(),
    SearchPage(),
    AddPropertyPage(),
    FavoritesPage(),
    ChatPage(),      // جديد: صفحة الرسائل
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
  }

  Future<void> _loadNotificationPreference() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final uid = auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (!mounted) return;
      setState(() {
        _notificationsEnabled = userDoc.data()?['notificationsEnabled'] ?? true;
      });
    } catch (e) {
      debugPrint('[MainPageWrapper] Error loading notification preference: $e');
    }
  }

  Future<void> _toggleNotifications() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final uid = auth.currentUser?.uid;
    if (uid == null) return;

    final newValue = !_notificationsEnabled;

    try {
      if (newValue) {
        // Enable notifications: subscribe to topics
        await FCMService.subscribeUserTopics(uid);
      } else {
        // Disable notifications: unsubscribe from topics
        await FCMService.unsubscribeUserTopics(uid);
      }

      // Update user preference in Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'notificationsEnabled': newValue,
      });

      if (!mounted) return;
      setState(() => _notificationsEnabled = newValue);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProv = Provider.of<ThemeProvider>(context);
    final titles = [
      'Accueil',
      'Rechercher',
      'Publier',
      'Favoris',
      'Messages',   // عنوان التاب الجديد
      'Profil',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedIndex]),
        actions: [
          IconButton(
            icon: Icon(
              _notificationsEnabled
                  ? Icons.notifications_active
                  : Icons.notifications_off,
            ),
            onPressed: _toggleNotifications,
            tooltip: _notificationsEnabled
                ? 'Désactiver les notifications'
                : 'Activer les notifications',
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () => themeProv.toggle(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                width: 48,
                height: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: themeProv.isDark
                      ? Colors.grey[700]
                      : Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.8),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOut,
                      left: themeProv.isDark ? 22 : 4,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Icon(
                          themeProv.isDark
                              ? Icons.nightlight_round
                              : Icons.wb_sunny,
                          key: ValueKey<bool>(themeProv.isDark),
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Builder(
        builder: (context) {
          final auth = Provider.of<AuthService>(context);
          final uid = auth.currentUser?.uid;

          final unreadStream = uid == null
              ? Stream<QuerySnapshot>.empty()
              : FirebaseFirestore.instance
                  .collectionGroup('messages')
                  .where('toId', isEqualTo: uid)
                  .where('isRead', isEqualTo: false)
                  .snapshots();

          return StreamBuilder<QuerySnapshot>(
            stream: unreadStream,
            builder: (context, snap) {
              final unreadCount =
                  snap.hasData ? snap.data!.docs.length : 0;

              return BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: (index) => setState(() => _selectedIndex = index),
                backgroundColor: Theme.of(context)
                    .bottomNavigationBarTheme
                    .backgroundColor,
                selectedItemColor: Theme.of(context)
                    .bottomNavigationBarTheme
                    .selectedItemColor,
                unselectedItemColor: Theme.of(context)
                    .bottomNavigationBarTheme
                    .unselectedItemColor,
                type: BottomNavigationBarType.fixed,
                items: [
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home),
                    label: 'Accueil',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.search_outlined),
                    activeIcon: Icon(Icons.search),
                    label: 'Rechercher',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.add_box_outlined),
                    activeIcon: Icon(Icons.add_box),
                    label: 'Publier',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.favorite_border),
                    activeIcon: Icon(Icons.favorite),
                    label: 'Favoris',
                  ),

                  // جديد: تاب Messages مع badge للـunread
                  BottomNavigationBarItem(
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(Icons.chat_bubble_outline),
                        if (unreadCount > 0)
                          Positioned(
                            right: -6,
                            top: -6,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 20,
                                minHeight: 20,
                              ),
                              child: Center(
                                child: Text(
                                  unreadCount > 99 ? '99+' : '$unreadCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    activeIcon: const Icon(Icons.chat_bubble),
                    label: 'Messages',
                  ),

                  const BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    activeIcon: Icon(Icons.person),
                    label: 'Profil',
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
