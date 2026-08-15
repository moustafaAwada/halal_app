import 'package:flutter/material.dart';
import 'package:halal_app/core/theme/app_colors.dart';

class CheckoutPage extends StatefulWidget {
  final double currentBalance;
  final double totalAmount;

  const CheckoutPage({
    super.key,
    this.currentBalance = 1500.0, // Default values for preview
    this.totalAmount = 450.0,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool _isLoading = false;
  int _selectedPaymentMethod = 1; // 1 = Wallet, 2 = Card

  bool get _hasSufficientBalance => widget.currentBalance >= widget.totalAmount;
  double get _remainingBalance => widget.currentBalance - widget.totalAmount;

  void _confirmPayment() {
    setState(() => _isLoading = true);
    // Simulate payment processing
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSuccessDialog();
      }
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green.shade500,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Payment Successful!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your transaction of ${widget.totalAmount.toStringAsFixed(0)} EGP was successful.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Go back
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Back to Home', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF1E3A8A)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildOrderSummary(),
                    const SizedBox(height: 32),
                    const Text(
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildWalletOption(),
                    const SizedBox(height: 16),
                    _buildCardOption(),
                    const SizedBox(height: 16),
                    _buildCashOnDeliveryOption(),
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ORDER TOTAL',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: Color(0xFF4B5563),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              widget.totalAmount.toStringAsFixed(0),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
                height: 1,
              ),
            ),
            const SizedBox(width: 8),
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'EGP',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Premium Tech Subscription - 1 Year',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF4B5563),
          ),
        ),
      ],
    );
  }

  Widget _buildWalletOption() {
    final bool isSelected = _selectedPaymentMethod == 1;

    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = 1),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF818CF8) : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF818CF8).withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF4338CA) : const Color(0xFFF3F4F6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_outlined,
                    color: isSelected ? Colors.white : const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'My Wallet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            _hasSufficientBalance ? Icons.check_circle_outline : Icons.error_outline,
                            size: 14,
                            color: _hasSufficientBalance ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _hasSufficientBalance ? 'Sufficient Funds' : 'Insufficient Funds',
                            style: TextStyle(
                              fontSize: 12,
                              color: _hasSufficientBalance ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: isSelected ? const Color(0xFF4338CA) : const Color(0xFFD1D5DB),
                ),
              ],
            ),
            if (isSelected) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(height: 1, color: Color(0xFFC7D2FE)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Balance',
                        style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Color(0xFF111827)),
                          children: [
                            TextSpan(
                              text: '${widget.currentBalance.toStringAsFixed(0)} ',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(text: 'EGP', style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'After payment',
                        style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _hasSufficientBalance
                            ? '${_remainingBalance.toStringAsFixed(0)} EGP'
                            : 'N/A',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _hasSufficientBalance ? const Color(0xFF059669) : const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (!_hasSufficientBalance) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 20),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Insufficient balance.\n\nPlease top up your wallet to proceed with this payment.',
                              style: TextStyle(fontSize: 13, color: Color(0xFF991B1B)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            // Navigate to Wallet Top-up
                            Navigator.pushNamed(context, '/wallet-top-up');
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFDC2626),
                            side: const BorderSide(color: Color(0xFFDC2626)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Top-up Wallet'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCardOption() {
    final bool isSelected = _selectedPaymentMethod == 2;

    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = 2),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF818CF8) : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFFE0E7FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.credit_card_outlined, color: Color(0xFF4338CA)),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'Credit / Debit Card',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF111827),
                ),
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? const Color(0xFF4338CA) : const Color(0xFFD1D5DB),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashOnDeliveryOption() {
    final bool isSelected = _selectedPaymentMethod == 3;

    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = 3),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF818CF8) : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFFE0E7FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delivery_dining_outlined, color: Color(0xFF4338CA)),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'Cash on Delivery',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF111827),
                ),
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? const Color(0xFF4338CA) : const Color(0xFFD1D5DB),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final bool isWalletSelectedAndInsufficient =
        _selectedPaymentMethod == 1 && !_hasSufficientBalance;
    final bool isButtonDisabled = isWalletSelectedAndInsufficient || _isLoading;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 16, color: Color(0xFF4B5563)),
              ),
              Text(
                '${widget.totalAmount.toStringAsFixed(0)} EGP',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isButtonDisabled ? null : _confirmPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFF9CA3AF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: isButtonDisabled ? 0 : 2,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isWalletSelectedAndInsufficient ? Icons.lock_outline : Icons.lock,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Confirm Payment',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
