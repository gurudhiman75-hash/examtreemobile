import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({
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
    final orderLabel = orderNumber.trim().isNotEmpty ? orderNumber : orderId;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAFBF4),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF13A875).withValues(alpha: .16),
                      blurRadius: 30,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Color(0xFF13A875),
                  size: 62,
                ),
              ),
            ),
            const SizedBox(height: 26),
            const Text(
              'Subscription Renewed!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF1118A8),
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your test series has been successfully activated. Your preparation can continue without interruption.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF3563D8),
                height: 1.45,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 24),
            _Card(
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.verified_rounded,
                          color: Color(0xFF13A875), size: 25),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Access Active',
                          style: TextStyle(
                            color: Color(0xFF081847),
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      _Pill(label: 'Active'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 14),
                  const _Feature(
                    icon: Icons.description_rounded,
                    title: 'Mock Tests',
                    subtitle: 'Full access to your purchased series',
                  ),
                  const _Feature(
                    icon: Icons.bar_chart_rounded,
                    title: 'Detailed Analysis',
                    subtitle: 'Track attempts, accuracy and progress',
                  ),
                  const _Feature(
                    icon: Icons.language_rounded,
                    title: 'Bilingual Content',
                    subtitle: 'Use supported languages throughout the series',
                  ),
                  const _Feature(
                    icon: Icons.lightbulb_outline_rounded,
                    title: 'Detailed Solutions',
                    subtitle: 'Review explanations after every attempt',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _Card(
              child: Column(
                children: [
                  const _Feature(
                    icon: Icons.shield_outlined,
                    title: 'Your Progress is Safe',
                    subtitle:
                        'Attempts, analytics and bookmarks are preserved with your access.',
                  ),
                  const Divider(height: 20),
                  const _Feature(
                    icon: Icons.workspace_premium_outlined,
                    title: 'Start Learning Now',
                    subtitle:
                        'Continue from where you left off and keep your preparation on track.',
                  ),
                  if (orderLabel.trim().isNotEmpty) ...[
                    const Divider(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.receipt_long_rounded,
                            color: Color(0xFF1A73E8)),
                        const SizedBox(width: 10),
                        const Text(
                          'Order',
                          style: TextStyle(color: Color(0xFF60759B)),
                        ),
                        const Spacer(),
                        Flexible(
                          child: Text(
                            orderLabel,
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF10264A),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              height: 56,
              child: FilledButton(
                onPressed: () => context.go(
                  '/test-series?id=' + Uri.encodeQueryComponent(seriesId),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0A57E6),
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
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.arrow_forward_rounded),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 54,
              child: OutlinedButton.icon(
                onPressed: () => context.push(
                  Uri(
                    path: '/order-details',
                    queryParameters: {
                      'seriesId': seriesId,
                      'orderId': orderId,
                      'orderNumber': orderNumber,
                    },
                  ).toString(),
                ),
                icon: const Icon(Icons.receipt_long_outlined),
                label: const Text(
                  'View Receipt',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0A57E6),
                  side: const BorderSide(color: Color(0xFF0A57E6)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ],
        ),
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
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10264A).withValues(alpha: .04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: child,
      );
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFDFF8EE),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF087653),
            fontWeight: FontWeight.w800,
          ),
        ),
      );
}

class _Feature extends StatelessWidget {
  const _Feature({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF5FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF1473E6), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF081847),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF60759B),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
