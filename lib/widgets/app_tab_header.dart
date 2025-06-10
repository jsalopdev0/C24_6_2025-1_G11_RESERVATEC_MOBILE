import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class AppTabHeader extends StatelessWidget {
  final String title;

  const AppTabHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class AppTabHeaderAcciones extends StatelessWidget {
  final String title;
  final List<Widget> acciones;

  const AppTabHeaderAcciones({
    super.key,
    required this.title,
    this.acciones = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center, 
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: acciones
                .map((icon) => Padding(
                      padding: EdgeInsets.only(left: 8.w),
                      child: SizedBox(
                        height: 24.sp,
                        width: 24.sp,
                        child: icon,
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

