// widgets/horario_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HorarioCard extends StatelessWidget {
  final String horario;
  final VoidCallback onTap;

  const HorarioCard({
    super.key,
    required this.horario,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        elevation: 2,
        margin: EdgeInsets.only(bottom: 12.h),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
          child: Text(
            horario,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}
