import 'package:flutter/material.dart';

class ServiceSkeletonCard extends StatelessWidget {
  const ServiceSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // image skeleton
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _line(width: double.infinity),
                  const SizedBox(height: 8),
                  _line(width: 120),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _line({required double width}) {
    return Container(
      height: 14,
      width: width,
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
