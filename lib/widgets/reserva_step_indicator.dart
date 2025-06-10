import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReservaStepIndicator extends StatelessWidget {
  final int activeStep;
  final int totalSteps;

  const ReservaStepIndicator({
    super.key,
    required this.activeStep,
    this.totalSteps = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final isActive = index == activeStep;
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          width: 30.w,
          height: 30.w,
          decoration: BoxDecoration(
            color: isActive ? Colors.lightBlue : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '${index + 1}',
            style: TextStyle(
              color: isActive ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
        );
      }),
    );
  }
}
