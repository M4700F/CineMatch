import 'package:flutter/material.dart';
import 'dart:async';

/// A modern, visually appealing email verification banner widget
/// that displays when a user's email is not verified.
///
/// Features:
/// - Smooth slide and fade-in animations
/// - Gradient background with shadow effects
/// - Resend email functionality with cooldown timer
/// - Responsive design for different screen sizes
/// - Material Design 3 compliant
/// - Dismissible with optional callback
/// - Animated pulse effect on the warning icon
/// - Auto-disable resend button during cooldown period
class EmailVerificationBanner extends StatefulWidget {
  /// The email address that needs verification
  final String email;

  /// Callback function when the resend email button is pressed
  final VoidCallback onResendEmail;

  /// Optional callback when the banner is dismissed
  final VoidCallback? onDismiss;

  /// Duration of the cooldown period between resend attempts (default: 60 seconds)
  final Duration cooldownDuration;

  /// Whether to show the dismiss button (default: true)
  final bool showDismissButton;

  const EmailVerificationBanner({
    super.key,
    required this.email,
    required this.onResendEmail,
    this.onDismiss,
    this.cooldownDuration = const Duration(seconds: 60),
    this.showDismissButton = true,
  });

  @override
  State<EmailVerificationBanner> createState() =>
      _EmailVerificationBannerState();
}

class _EmailVerificationBannerState extends State<EmailVerificationBanner>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // Cooldown timer state
  bool _isResendCooldown = false;
  int _cooldownSeconds = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();

    // Main slide and fade animation
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1.0), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
        );

    // Pulse animation for the warning icon
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start entrance animation
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  /// Handle resend email button press with cooldown timer
  void _handleResendEmail() {
    if (_isResendCooldown) return;

    // Call the parent callback
    widget.onResendEmail();

    // Start cooldown
    setState(() {
      _isResendCooldown = true;
      _cooldownSeconds = widget.cooldownDuration.inSeconds;
    });

    // Start countdown timer
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _cooldownSeconds--;
        if (_cooldownSeconds <= 0) {
          _isResendCooldown = false;
          timer.cancel();
        }
      });
    });
  }

  /// Handle dismiss with animation
  void _handleDismiss() async {
    await _slideController.reverse();
    widget.onDismiss?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: EdgeInsets.only(
            bottom: 16,
            left: isSmallScreen ? 0 : 8,
            right: isSmallScreen ? 0 : 8,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDarkMode
                  ? [const Color(0xFFFF6F00), const Color(0xFFE65100)]
                  : [const Color(0xFFFF9800), const Color(0xFFF57C00)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color:
                    (isDarkMode
                            ? const Color(0xFFFF6F00)
                            : const Color(0xFFFF9800))
                        .withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {}, // Prevents clicks from passing through
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header Section
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Animated Warning Icon
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.2),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.mark_email_unread_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Title and Description
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Email Not Verified',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Please check your inbox and verify your email to access all features.',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.95),
                                    fontSize: 14,
                                    height: 1.5,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Dismiss Button
                          if (widget.showDismissButton &&
                              widget.onDismiss != null)
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _handleDismiss,
                                borderRadius: BorderRadius.circular(24),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Icon(
                                    Icons.close_rounded,
                                    color: Colors.white.withOpacity(0.9),
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Divider
                      Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.0),
                              Colors.white.withOpacity(0.3),
                              Colors.white.withOpacity(0.0),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Email Display Section
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.email_outlined,
                              size: 18,
                              color: Colors.white.withOpacity(0.95),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                widget.email,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Action Buttons Section
                      if (isSmallScreen)
                        // Stack buttons vertically on small screens
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildResendButton(isDarkMode),
                            const SizedBox(height: 12),
                            _buildInfoSection(),
                          ],
                        )
                      else
                        // Show buttons horizontally on larger screens
                        Row(
                          children: [
                            Expanded(child: _buildInfoSection()),
                            const SizedBox(width: 12),
                            _buildResendButton(isDarkMode),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build the info section with inbox hint
  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: Colors.white.withOpacity(0.9),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Check your inbox & spam',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build the resend email button with cooldown timer
  Widget _buildResendButton(bool isDarkMode) {
    return ElevatedButton.icon(
      onPressed: _isResendCooldown ? null : _handleResendEmail,
      icon: Icon(
        _isResendCooldown ? Icons.timer_outlined : Icons.send_rounded,
        size: 20,
      ),
      label: Text(
        _isResendCooldown ? 'Wait ${_cooldownSeconds}s' : 'Resend Email',
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          letterSpacing: 0.5,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: _isResendCooldown
            ? Colors.grey.shade600
            : const Color(0xFFE65100),
        disabledBackgroundColor: Colors.white.withOpacity(0.7),
        disabledForegroundColor: Colors.grey.shade500,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        shadowColor: Colors.black26,
      ),
    );
  }
}
