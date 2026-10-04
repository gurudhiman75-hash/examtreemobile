import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({
    super.key,
    required this.seriesId,
    required this.orderId,
    required this.orderNumber,
  });

  final String seriesId;
  final String orderId;
  final String orderNumber;

  @override
  Widget build(BuildContext context) {
    final displayOrder = orderNumber.trim().isNotEmpty ? orderNumber : orderId;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      appBar: AppBar(
        title: const Text(
          'Order Details',
          style: TextStyle(
            color: Color(0xFF081847),
            fontWeight: FontWeight.w900,
          ),
        ),
        backgroundColor: const Color(0xFFF8FBFF),
        foregroundColor: const Color(0xFF081847),
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEAFBF3),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFBFEBD6)),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Color(0xFF12A875),
                  child: Icon(Icons.check_rounded, color: Colors.white, size: 30),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Successful',
                        style: TextStyle(
                          color: Color(0xFF087653),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Your Test Series is now active!',
                        style: TextStyle(color: Color(0xFF4A7C6A)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Transaction Details',
                  style: TextStyle(
                    color: Color(0xFF081847),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                _Row(label: 'Order ID', value: displayOrder),
                const Divider(height: 24),
                _Row(
                  label: 'Transaction ID',
                  value: orderId.trim().isEmpty ? 'Confirmed by payment provider' : orderId,
                ),
                const Divider(height: 24),
                const _Row(label: 'Status', value: 'Paid · Access activated'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Included in your access',
                  style: TextStyle(
                    color: Color(0xFF081847),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 12),
                _Included(text: 'Full-length mock tests'),
                _Included(text: 'Sectional and topic-wise tests'),
                _Included(text: 'Previous year papers'),
                _Included(text: 'Detailed solutions and performance analysis'),
                _Included(text: 'Bilingual content where available'),
              ],
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 54,
            child: FilledButton(
              onPressed: () => context.go(
                '/my-test-series?seriesId=' + Uri.encodeQueryComponent(seriesId),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF073A6A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Go to My Test Series',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_forward_rounded),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE4ECF6)),
        ),
        child: child,
      );
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF60759B)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF10264A),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      );
}

class _Included extends StatelessWidget {
  const _Included({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Color(0xFF13A875), size: 20),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: Color(0xFF425D89),
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      );
}
