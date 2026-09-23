import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../utils/app_theme.dart';

class WeatherCard extends StatelessWidget {
  final WeatherModel? weather;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;

  const WeatherCard({
    super.key,
    required this.weather,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radius),
      ),
      child: isLoading
          ? const SizedBox(
              height: 70,
              child: Center(child: CircularProgressIndicator(color: Colors.white)),
            )
          : errorMessage != null
              ? Row(
                  children: [
                    const Icon(Icons.cloud_off, color: Colors.white70),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text('ดึงข้อมูลสภาพอากาศไม่สำเร็จ',
                          style: TextStyle(color: Colors.white)),
                    ),
                    IconButton(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh, color: Colors.white),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Icon(
                      weather!.isRainy ? Icons.umbrella : Icons.wb_sunny,
                      color: Colors.white,
                      size: 40,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${weather!.temperature.toStringAsFixed(0)}°C  •  ${weather!.description}',
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            weather!.laundryAdvice,
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
