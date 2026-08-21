import 'package:flutter/material.dart';

import '../../../../../core/utils/SyncColor.dart';
import '../../../data/models/TienDoCongTrinhModel.dart';
import 'card.dart';
import 'statusBadge.dart';
import 'warningBox.dart';

Widget buildOverview(
    TienDoCongTrinhModel model,
    Color progressColor,
    bool isTreDeadline,
    IconData statusIcon,
    String statusText,
    ) {
  final progress = (model.phanTramThucTe ?? 0).clamp(0, 100).toDouble();

  return Row(
    // 🔴 ĐÃ SỬA: Đổi từ CrossAxisAlignment.stretch sang CrossAxisAlignment.start
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        flex: 3,
        child: card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: progressColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.work_outline,
                        color: progressColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        model.tenCongViec,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xff1e293b),
                        ),
                      ),
                    ),
                    SyncColor.icon(
                      model.isSynced,
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                statusBadge(progressColor, statusIcon, statusText),
                if (isTreDeadline) ...[
                  const SizedBox(height: 14),
                  warningBox(),
                ],
              ],
            ),
          ),
        ),
      ),
      const SizedBox(width: 18),
      Expanded(
        flex: 2,
        child: card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Tiến độ thực tế',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff64748b),
                        ),
                      ),
                    ),
                    Text(
                      '${progress.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: progressColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    minHeight: 12,
                    backgroundColor: const Color(0xffe2e8f0),
                    color: progressColor,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '0%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    Text(
                      '100%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}