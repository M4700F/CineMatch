import 'package:flutter/material.dart';
import 'email_verification_banner.dart';

/// Example screen demonstrating various use cases of EmailVerificationBanner
///
/// This file shows:
/// - Basic usage
/// - Custom cooldown duration
/// - With and without dismiss button
/// - Different screen layouts
/// - Integration with different UI patterns
class EmailVerificationBannerExample extends StatefulWidget {
  const EmailVerificationBannerExample({super.key});

  @override
  State<EmailVerificationBannerExample> createState() =>
      _EmailVerificationBannerExampleState();
}

class _EmailVerificationBannerExampleState
    extends State<EmailVerificationBannerExample> {
  bool _showBanner1 = true;
  bool _showBanner2 = true;
  bool _showBanner3 = true;
  final String _testEmail = 'john.doe@example.com';

  /// Simulate resending verification email
  Future<void> _handleResendEmail(String bannerName) async {
    print('📧 Resending verification email for $bannerName');

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text('Verification email sent to $_testEmail')),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Verification Banner Examples'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Banner Variations',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Different configurations and use cases',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),

            // Example 1: Standard Banner with Dismiss
            _buildSectionHeader(
              context,
              '1. Standard Banner',
              'Default settings with 60s cooldown and dismiss button',
            ),
            const SizedBox(height: 12),
            if (_showBanner1)
              EmailVerificationBanner(
                email: _testEmail,
                onResendEmail: () => _handleResendEmail('Banner 1'),
                onDismiss: () {
                  setState(() => _showBanner1 = false);
                },
              )
            else
              _buildShowBannerButton('Show Banner 1', () {
                setState(() => _showBanner1 = true);
              }),

            const SizedBox(height: 40),

            // Example 2: Custom Cooldown Duration
            _buildSectionHeader(
              context,
              '2. Custom Cooldown (2 minutes)',
              'Extended cooldown period for rate limiting',
            ),
            const SizedBox(height: 12),
            if (_showBanner2)
              EmailVerificationBanner(
                email: _testEmail,
                onResendEmail: () => _handleResendEmail('Banner 2'),
                onDismiss: () {
                  setState(() => _showBanner2 = false);
                },
                cooldownDuration: const Duration(minutes: 2),
              )
            else
              _buildShowBannerButton('Show Banner 2', () {
                setState(() => _showBanner2 = true);
              }),

            const SizedBox(height: 40),

            // Example 3: No Dismiss Button
            _buildSectionHeader(
              context,
              '3. No Dismiss Button',
              'Use in critical flows where verification is required',
            ),
            const SizedBox(height: 12),
            if (_showBanner3)
              EmailVerificationBanner(
                email: _testEmail,
                onResendEmail: () => _handleResendEmail('Banner 3'),
                showDismissButton: false,
              ),

            if (!_showBanner3)
              _buildShowBannerButton('Show Banner 3', () {
                setState(() => _showBanner3 = true);
              }),

            const SizedBox(height: 40),

            // Example 4: In a Form Context
            _buildSectionHeader(
              context,
              '4. Integration with Form',
              'Banner shown above a form card',
            ),
            const SizedBox(height: 12),
            EmailVerificationBanner(
              email: _testEmail,
              onResendEmail: () => _handleResendEmail('Form Banner'),
              cooldownDuration: const Duration(seconds: 30),
            ),
            const SizedBox(height: 16),
            _buildExampleFormCard(),

            const SizedBox(height: 40),

            // Example 5: Long Email Address
            _buildSectionHeader(
              context,
              '5. Long Email Address',
              'Demonstrates text overflow handling',
            ),
            const SizedBox(height: 12),
            EmailVerificationBanner(
              email:
                  'very.long.email.address.for.testing@subdomain.example.com',
              onResendEmail: () => _handleResendEmail('Long Email Banner'),
            ),

            const SizedBox(height: 40),

            // Usage Tips
            _buildUsageTips(context),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    String description,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildShowBannerButton(String text, VoidCallback onPressed) {
    return Center(
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.visibility),
        label: Text(text),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildExampleFormCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Display Name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              initialValue: 'John Doe',
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
                enabled: false,
              ),
              initialValue: _testEmail,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: null,
                child: const Text('Save Changes'),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Verify your email to enable editing',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.orange.shade700,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageTips(BuildContext context) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.blue.shade700,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Usage Tips',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.blue.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTipItem(
              '✅ Use at the top of forms where email verification is required',
            ),
            _buildTipItem(
              '✅ Implement proper error handling in onResendEmail callback',
            ),
            _buildTipItem(
              '✅ Adjust cooldown duration based on your rate limiting needs',
            ),
            _buildTipItem(
              '✅ Use showDismissButton: false for critical verification flows',
            ),
            _buildTipItem(
              '✅ Test with different email lengths to ensure proper overflow handling',
            ),
            _buildTipItem(
              '✅ Provide clear user feedback after resending email',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(color: Colors.blue.shade900, height: 1.5),
      ),
    );
  }
}

// ============================================================================
// Additional Example: Integration in a Real Login Flow
// ============================================================================

class LoginWithVerificationExample extends StatefulWidget {
  const LoginWithVerificationExample({super.key});

  @override
  State<LoginWithVerificationExample> createState() =>
      _LoginWithVerificationExampleState();
}

class _LoginWithVerificationExampleState
    extends State<LoginWithVerificationExample> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showVerificationBanner = false;
  String? _unverifiedEmail;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      // Simulate login API call
      await Future.delayed(const Duration(seconds: 1));

      // Simulate email not verified error
      setState(() {
        _showVerificationBanner = true;
        _unverifiedEmail = _emailController.text;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login failed: Email not verified'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _resendVerification() async {
    print('📧 Resending to $_unverifiedEmail');
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Verification email sent to $_unverifiedEmail'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _dismissBanner() {
    setState(() {
      _showVerificationBanner = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Example')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),

            // App Logo
            Icon(
              Icons.movie,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text('CineMatch', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 48),

            // Verification Banner
            if (_showVerificationBanner && _unverifiedEmail != null)
              EmailVerificationBanner(
                email: _unverifiedEmail!,
                onResendEmail: _resendVerification,
                onDismiss: _dismissBanner,
              ),

            // Login Form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _login,
                          child: const Padding(
                            padding: EdgeInsets.all(12),
                            child: Text('Sign In'),
                          ),
                        ),
                      ),
                    ],
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
