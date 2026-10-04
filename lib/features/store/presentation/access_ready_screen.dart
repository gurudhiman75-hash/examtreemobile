import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AccessReadyScreen extends StatelessWidget {
  const AccessReadyScreen({
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 34, 20, 28),
          children: [
            Center(
              child: Container(
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAFBF4),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF13A875).withValues(alpha: .15),
                      blurRadius: 28,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: Color(0xFF13A875),
                  size: 56,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'You’re All Set!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF081847),
                fontSize: 29,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your ExamTree test series is active and ready to use.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF60759B),
                fontSize: 15,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            const _StepCard(
              number: '1',
              icon: Icons.fact_check_outlined,
              title: 'Open your Test Series',
              body: 'Your purchased series now appears in My Test Series.',
            ),
            const SizedBox(height: 10),
            const _StepCard(
              number: '2',
              icon: Icons.play_circle_outline_rounded,
              title: 'Choose a test',
              body: 'Start with a full mock, sectional, PYQ or topic-wise test.',
            ),
            const SizedBox(height: 10),
            const _StepCard(
              number: '3',
              icon: Icons.insights_outlined,
              title: 'Track your performance',
              body: 'Review scores, accuracy, attempts and progress from your Profile.',
            ),
            const SizedBox(height: 22),
            SizedBox(
              height: 56,
              child: FilledButton(
                onPressed: () => context.go(
                  '/my-test-series?seriesId=' +
                      Uri.encodeQueryComponent(seriesId),
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
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.arrow_forward_rounded),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 52,
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
                  'View Order Details',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0A57E6),
                  side: const BorderSide(color: Color(0xFFB7CBE7)),
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

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.number,
    required this.icon,
    required this.title,
    required this.body,
  });

  final String number;
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4ECF6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFF073A6A),
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF5FF),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: const Color(0xFF176CC0)),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF10264A),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: const TextStyle(
                    color: Color(0xFF60759B),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
