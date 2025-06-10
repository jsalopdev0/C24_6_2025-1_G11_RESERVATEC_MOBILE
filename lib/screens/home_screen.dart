import 'package:flutter/material.dart';
import 'package:reservatec/screens/tabs/inicio_tab.dart';
import 'package:reservatec/screens/tabs/mis_reservas_tab.dart';
import 'package:reservatec/screens/tabs/reservar_tab.dart';
import 'package:reservatec/screens/tabs/notificaciones_tab.dart';
import 'package:reservatec/screens/tabs/perfil_tab.dart';

class HomeScreen extends StatefulWidget {
  final String name;
  final String email;
  final String photoUrl;
  final String accessToken;
  final int initialTabIndex;
  final int userId;

  const HomeScreen({
    super.key,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.accessToken,
    this.initialTabIndex = 0,
    required this.userId,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialTabIndex;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // 🔒 Bloquea botón y gesto de retroceso
      child: Scaffold(
        body: IndexedStack(
          index: currentIndex,
          children: [
            InicioTab(
              onReservarAhora: () {
                setState(() {
                  currentIndex = 2;
                });
              },
            ),
            MisReservasTab(usuarioId: widget.userId),
            const ReservarTab(),
            const NotificacionesTab(),
            const PerfilTab(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF00AEEF),
          unselectedItemColor: const Color.fromARGB(255, 84, 83, 83),
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          iconSize: 24,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today), label: 'Historial'),
            BottomNavigationBarItem(
                icon: Icon(Icons.add_box), label: 'Reservar'),
            BottomNavigationBarItem(
                icon: Icon(Icons.notifications), label: 'Alertas'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          ],
        ),
      ),
    );
  }
}
