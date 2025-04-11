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
  final int initialTabIndex; // ✅ nuevo parámetro para controlar el tab inicial

  const HomeScreen({
    super.key,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.accessToken,
    this.initialTabIndex = 0, // ✅ por defecto: tab de Inicio
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialTabIndex; // ✅ inicia con el índice recibido
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      const InicioTab(),
      const MisReservasTab(),
      const ReservarTab(),
      const NotificacionesTab(),
      const PerfilTab(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF00AEEF),
        unselectedItemColor: const Color.fromARGB(255, 84, 83, 83),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        iconSize: 24,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Mis reservas'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Reservar'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notificaciones'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
