import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:reservatec/services/storage.dart';

class InicioTab extends StatefulWidget {
  const InicioTab({super.key});

  @override
  State<InicioTab> createState() => _InicioTabState();
}

class _InicioTabState extends State<InicioTab> {
  String userName = '';
  int _currentPage = 0;
  final PageController _pageController = PageController();

  final List<String> frases = [
    'En la cancha, como en la vida,\nlos retos están para superarlos.',
    'El juego limpio también\nse juega fuera del campo.',
    'Haz de cada reserva una victoria\npersonal.',
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final session = await Storage.getUserSession();
    if (session != null && session["name"] != null) {
      setState(() {
        userName = session["name"]!.split(' ').first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedOpacity(
              opacity: userName.isEmpty ? 0 : 1,
              duration: const Duration(milliseconds: 800),
              child: Text(
                "Hola, $userName 👋",
                style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 24.h),

            // ⛅ Clima y Próxima reserva
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 157.h,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Lima, Perú",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp)),
                        SizedBox(height: 6.h),
                        Text("☀️ 34°", style: TextStyle(fontSize: 28.sp)),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Container(
                    height: 157.h,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Tu próxima\nreserva empieza en",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                height: 1.3)),
                        const Spacer(),
                        CircleAvatar(
                          radius: 22.r,
                          backgroundColor: Colors.yellow,
                          child: Text("20 min",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // 🏃‍♂️ Bienestar card
            Container(
              height: 180.h,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                color: const Color(0xFF00BDF0),
                image: const DecorationImage(
                  image: AssetImage('assets/images/player.jpeg'),
                  alignment: Alignment.centerRight,
                  fit: BoxFit.contain,
                ),
              ),
              padding: EdgeInsets.all(16.w),
              child: Text(
                'Porque tu bienestar\nempieza aquí:\nreserva, juega\ny gana',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // 🎯 Frases motivacionales - PageView
            SizedBox(
              height: 158.h,
              child: PageView.builder(
                controller: _pageController,
                itemCount: frases.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 6.w),
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      image: const DecorationImage(
                        image: AssetImage("assets/images/cancha_bg.jpeg"),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black54,
                          BlendMode.darken,
                        ),
                      ),
                    ),
                    child: Text(
                      frases[index],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 12.h),
            // Indicadores
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(frases.length, (index) {
                final isActive = _currentPage == index;
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  width: isActive ? 12.w : 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.blue : Colors.grey,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                );
              }),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}
