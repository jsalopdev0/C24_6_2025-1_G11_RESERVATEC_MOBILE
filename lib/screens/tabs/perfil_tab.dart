import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:http/http.dart' as http;
import 'package:reservatec/services/auth_service.dart';
import 'package:reservatec/services/storage.dart';
import 'package:reservatec/services/unsafe_http_client.dart';
import 'package:reservatec/screens/login_screen.dart';
import 'package:reservatec/widgets/app_tab_header.dart';

class PerfilTab extends StatefulWidget {
  const PerfilTab({super.key});

  @override
  State<PerfilTab> createState() => _PerfilTabState();
}

class _PerfilTabState extends State<PerfilTab> {
  Future<Map<String, dynamic>?> fetchPerfil() async {
    final session = await Storage.getUserSession();
    final token = session?["token"];
    final client = UnsafeHttpClient.create();

    if (token == null) return null;

    const String url = 'https://reservatec-tesis-backend-8asuen-298379-31-220-104-112.traefik.me/api/usuarios/perfil';

    try {
      final response = await client.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        print("❌ Error perfil: ${response.statusCode} ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Error de conexión: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchPerfil(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          final nombre = data["name"] ?? '';
          final email = data["email"] ?? '';
          final codigo = data["code"] ?? '';
          final carrera = data["carrera"] ?? '';
          final foto = data["foto"] ?? '';

          return SafeArea(
            child: Column(
              children: [
                const AppTabHeader(title: 'Perfil'),

                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    children: [
                      // Foto
                      Center(
                        child: Container(
                          width: 120.w,
                          height: 120.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: NetworkImage(
                                foto.isNotEmpty
                                    ? foto
                                    : 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(nombre)}&background=eeeeee&color=555555',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Info
                      Container(
                        margin: EdgeInsets.only(top: 8.h),
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 8)
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            infoItem('Usuario', nombre),
                            const Divider(),
                            infoItem('Email', email),
                            const Divider(),
                            infoItem('Código', codigo),
                            const Divider(),
                            infoItem('Carrera', carrera),
                          ],
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // Botón cerrar sesión
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await AuthService.signOut();
                            await Storage.clearSession();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                              (route) => false,
                            );
                          },
                          icon: const Icon(Icons.logout),
                          label: const Text(
                            'Cerrar sesión',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 32.h),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget infoItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp)),
          SizedBox(height: 2.h),
          Text(value,
              style: TextStyle(fontSize: 18.sp, color: Colors.black87)),
        ],
      ),
    );
  }
}
