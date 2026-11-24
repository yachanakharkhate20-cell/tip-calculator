import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The single screen of the app.
/// It is a StatefulWidget because the screen changes when the user
/// types a bill, moves the slider, or taps + / -.
class TipPage extends StatefulWidget {
  const TipPage({super.key});

  @override
  State<TipPage> createState() => _TipPageState();
}

class _TipPageState extends State<TipPage> {
  // ---------------------------------------------------------------------------
  // Colors (light, professional palette)
  // ---------------------------------------------------------------------------
  static const Color _primary = Color(0xFF4F46E5);
  static const Color _primaryDark = Color(0xFF3730A3);
  static const Color _textDark = Color(0xFF1F2937);
  static const Color _textMuted = Color(0xFF6B7280);

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------
  final TextEditingController _billController = TextEditingController();

  String _billText = ''; // what the user typed
  double tipPercent = 10; // slider value, 0 - 30
  int people = 1; // never below 1

  @override
  void dispose() {
    _billController.dispose(); // free memory when the screen is closed
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Calculations (getters always read the latest state)
  // ---------------------------------------------------------------------------

  /// Bill parsed safely: empty / invalid / negative input becomes 0.
  double get bill {
    final value = double.tryParse(_billText) ?? 0;
    return value < 0 ? 0 : value;
  }

  /// Number of people, guarded so we can never divide by zero.
  int get _safePeople => people < 1 ? 1 : people;

  double get tipAmount => bill * tipPercent / 100;

  double get totalAmount => bill + tipAmount;

  double get tipPerPerson => tipAmount / _safePeople;

  double get totalPerPerson => totalAmount / _safePeople;

  /// Formats a number as e.g. "₹275.00".
  String _money(double value) => '₹${value.toStringAsFixed(2)}';

  // ---------------------------------------------------------------------------
  // Event handlers (each one calls setState so the UI refreshes)
  // ---------------------------------------------------------------------------
  void _onBillChanged(String value) {
    setState(() => _billText = value);
  }

  void _onTipChanged(double value) {
    setState(() => tipPercent = value);
  }

  void _increasePeople() {
    setState(() => people++);
  }

  void _decreasePeople() {
    if (people > 1) {
      setState(() => people--);
    }
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        // Tap anywhere outside the text field to close the keyboard.
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  // Keeps the layout tidy on tablets / wide screens.
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: Column(
                      children: [
                        _buildBillCard(),
                        const SizedBox(height: 16),
                        _buildTipCard(),
                        const SizedBox(height: 16),
                        _buildPeopleCard(),
                        const SizedBox(height: 16),
                        _buildSummaryCard(),
                        const SizedBox(height: 16),
                        _buildTipAndTotalRow(),
                        const SizedBox(height: 16),
                        _buildTotalPerPersonCard(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----- Header --------------------------------------------------------------
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 20,
        20,
        24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_primary, _primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: const Row(
        children: [
          Icon(Icons.receipt_long_rounded, color: Colors.white, size: 32),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tip Calculator',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Split the bill, the easy way',
                style: TextStyle(color: Color(0xFFE0E7FF), fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ----- Bill input ----------------------------------------------------------
  Widget _buildBillCard() {
    return _SectionCard(
      title: 'Bill Amount',
      child: TextField(
        controller: _billController,
        onChanged: _onBillChanged,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          // Digits and one dot only, max 2 decimals. No minus sign, so
          // negative bills cannot be typed.
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
        ],
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: _textDark,
        ),
        decoration: InputDecoration(
          hintText: '0.00',
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 16, right: 8),
            child: Text(
              '₹',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: _primary,
              ),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          filled: true,
          fillColor: const Color(0xFFF3F4F6),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _primary, width: 2),
          ),
        ),
      ),
    );
  }

  // ----- Tip slider ----------------------------------------------------------
  Widget _buildTipCard() {
    return _SectionCard(
      title: 'Tip Percentage',
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFE0E7FF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '${tipPercent.round()}%',
          style: const TextStyle(
            color: _primary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      child: Column(
        children: [
          Slider(
            value: tipPercent,
            min: 0,
            max: 30,
            divisions: 30, // snaps to whole numbers
            label: '${tipPercent.round()}%',
            activeColor: _primary,
            onChanged: _onTipChanged,
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('0%', style: TextStyle(color: _textMuted)),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('30%', style: TextStyle(color: _textMuted)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ----- People counter ------------------------------------------------------
  Widget _buildPeopleCard() {
    return _SectionCard(
      title: 'Split Between',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _roundIconButton(
            icon: Icons.remove,
            onPressed: people > 1 ? _decreasePeople : null,
          ),
          Column(
            children: [
              Text(
                '$people',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: _textDark,
                ),
              ),
              Text(
                people == 1 ? 'person' : 'people',
                style: const TextStyle(color: _textMuted),
              ),
            ],
          ),
          _roundIconButton(icon: Icons.add, onPressed: _increasePeople),
        ],
      ),
    );
  }

  Widget _roundIconButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    final enabled = onPressed != null;
    return Container(
      decoration: BoxDecoration(
        color: enabled ? const Color(0xFFE0E7FF) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: IconButton(
        onPressed: onPressed,
        iconSize: 28,
        color: _primary,
        tooltip: icon == Icons.add ? 'Add person' : 'Remove person',
        icon: Icon(icon),
      ),
    );
  }

  // ----- Results -------------------------------------------------------------
  Widget _buildSummaryCard() {
    return _SectionCard(
      title: 'Summary',
      child: Column(
        children: [
          _summaryRow('Bill Amount', _money(bill)),
          const Divider(height: 24),
          _summaryRow('Tip Amount', _money(tipAmount)),
          const Divider(height: 24),
          _summaryRow('Total Amount', _money(totalAmount), bold: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: bold ? _textDark : _textMuted,
            fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 17,
                color: _textDark,
                fontWeight: bold ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTipAndTotalRow() {
    return Row(
      children: [
        Expanded(
          child: _MiniResultCard(
            label: 'Tip / Person',
            value: _money(tipPerPerson),
            icon: Icons.volunteer_activism_rounded,
            color: const Color(0xFF0EA5E9),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MiniResultCard(
            label: 'Total Amount',
            value: _money(totalAmount),
            icon: Icons.account_balance_wallet_rounded,
            color: const Color(0xFF10B981),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalPerPersonCard() {
    return Card(
      elevation: 4,
      color: _primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        child: Column(
          children: [
            const Text(
              'TOTAL PER PERSON',
              style: TextStyle(
                color: Color(0xFFC7D2FE),
                fontSize: 14,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                _money(totalPerPerson),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 46,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Reusable widgets
// =============================================================================

/// A rounded white card with a title. Used for every input/result section.
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({
    required this.title,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

/// Small card used for "Tip / Person" and "Total Amount".
class _MiniResultCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniResultCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
