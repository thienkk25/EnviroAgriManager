import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EnvironmentalMonitor extends StatelessWidget {
  const EnvironmentalMonitor({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5E81AC), Color(0xFF88C0D0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.eco,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Giám sát Môi trường',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Trực tiếp',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _EnvironmentalMetric(
                  icon: Icons.thermostat,
                  label: 'Nhiệt độ',
                  value: '28°C',
                  status: 'Bình thường',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _EnvironmentalMetric(
                  icon: Icons.water_drop,
                  label: 'Độ ẩm',
                  value: '75%',
                  status: 'Tốt',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _EnvironmentalMetric(
                  icon: Icons.water,
                  label: 'Độ ẩm đất',
                  value: '65%',
                  status: 'Tốt',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _EnvironmentalMetric(
                  icon: Icons.wb_sunny,
                  label: 'Ánh sáng',
                  value: '85%',
                  status: 'Tốt',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _EnvironmentalMetric(
                  icon: Icons.science,
                  label: 'Độ pH',
                  value: '6.5',
                  status: 'Tối ưu',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _EnvironmentalMetric(
                  icon: Icons.cloud,
                  label: 'Thời tiết',
                  value: 'Nắng',
                  status: 'Tốt',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EnvironmentalMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String status;

  const _EnvironmentalMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
