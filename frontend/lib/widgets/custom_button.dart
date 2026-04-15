/// Custom Button Widget with loading state
import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final bool isOutlined;
  final Color? color;
  final IconData? icon;
  final double? height;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
    this.isOutlined = false,
    this.color,
    this.icon,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final buttonChild = isLoading
        ? SizedBox(
            width: 22, height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation(
                isOutlined ? (color ?? AppTheme.primaryColor) : Colors.white,
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(text),
            ],
          );

    Widget button;
    
    if (isOutlined) {
      button = OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color ?? AppTheme.primaryColor, width: 1.5),
          foregroundColor: color ?? AppTheme.primaryColor,
          minimumSize: Size(isFullWidth ? double.infinity : 0, height ?? 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: buttonChild,
      );
    } else {
      button = ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppTheme.primaryColor,
          minimumSize: Size(isFullWidth ? double.infinity : 0, height ?? 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: buttonChild,
      );
    }

    return button;
  }
}

/// Gradient Button
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final LinearGradient? gradient;
  final IconData? icon;
  final bool isLoading;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.gradient,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        gradient: gradient ?? AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22, height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(text, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
