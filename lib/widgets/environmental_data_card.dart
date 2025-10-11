import 'package:enviro_agri_manager/models/environmental_data_model.dart';
import 'package:enviro_agri_manager/widgets/role_based_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class EnvironmentalDataCard extends StatelessWidget {
  final EnvironmentalDataModel environmentalData;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const EnvironmentalDataCard({
    super.key,
    required this.environmentalData,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Color(0xFF5E81AC),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      environmentalData.location ?? '',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2E3440),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFA3BE8C).withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      environmentalData.weatherCondition ?? '',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFA3BE8C),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Environmental Metrics
            Row(
              spacing: 5,
              children: [
                Expanded(
                  child: _MetricItem(
                    icon: Icons.thermostat,
                    label: 'Nhiệt độ',
                    value: '${environmentalData.temperature}°C',
                    color: const Color(0xFF5E81AC),
                  ),
                ),
                Expanded(
                  child: _MetricItem(
                    icon: Icons.water_drop,
                    label: 'Độ ẩm',
                    value: '${environmentalData.humidity}%',
                    color: const Color(0xFF88C0D0),
                  ),
                ),
                Expanded(
                  child: _MetricItem(
                    icon: Icons.science,
                    label: 'Độ pH',
                    value: '${environmentalData.ph}',
                    color: const Color(0xFFD08770),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              spacing: 5,
              children: [
                Expanded(
                  child: _MetricItem(
                    icon: Icons.water,
                    label: 'Độ ẩm đất',
                    value: '${environmentalData.soilMoisture}%',
                    color: const Color(0xFFA3BE8C),
                  ),
                ),
                Expanded(
                  child: _MetricItem(
                    icon: Icons.wb_sunny,
                    label: 'Ánh sáng',
                    value: '${environmentalData.lightIntensity}%',
                    color: const Color(0xFFB48EAD),
                  ),
                ),
                Expanded(
                  child: _MetricItem(
                    icon: Icons.cloud,
                    label: 'CO2',
                    value: '${environmentalData.co2Level} ppm',
                    color: const Color(0xFF88C0D0),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Nutrients
            Text(
              'Dinh dưỡng đất',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2E3440),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              spacing: 5,
              children: [
                Expanded(
                  child: _MetricItem(
                    icon: Icons.eco,
                    label: 'N',
                    value: '${environmentalData.nitrogen}%',
                    color: const Color(0xFF4CAF50),
                  ),
                ),
                Expanded(
                  child: _MetricItem(
                    icon: Icons.eco,
                    label: 'P',
                    value: '${environmentalData.phosphorus}%',
                    color: const Color(0xFF2196F3),
                  ),
                ),
                Expanded(
                  child: _MetricItem(
                    icon: Icons.eco,
                    label: 'K',
                    value: '${environmentalData.potassium}%',
                    color: const Color(0xFFFF9800),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Notes and Time
            if (environmentalData.notes == null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.note, color: Color(0xFF88C0D0), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        environmentalData.notes ?? '',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF2E3440),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ghi nhận: ${DateFormat('dd/MM/yyyy HH:mm').format(environmentalData.recordedAt)}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF88C0D0),
                  ),
                ),
                Row(
                  children: [
                    RoleBasedActionButton(
                      permission: 'edit',
                      child: IconButton(
                        icon: const Icon(Icons.edit, size: 16),
                        onPressed: onEdit,
                      ),
                    ),
                    RoleBasedActionButton(
                      permission: 'delete',
                      child: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          size: 16,
                          color: Colors.red,
                        ),
                        onPressed: onDelete,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2E3440),
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: const Color(0xFF88C0D0),
            ),
          ),
        ],
      ),
    );
  }
}
