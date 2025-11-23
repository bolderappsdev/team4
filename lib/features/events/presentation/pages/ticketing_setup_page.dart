import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:leadright/features/events/presentation/models/event_creation_data.dart';
import 'event_media_page.dart';

/// Second page in the event creation process (2/4).
/// Collects ticketing information: ticket name, price, availability, and early bird pricing.
class TicketingSetupPage extends StatefulWidget {
  final EventCreationData eventData;

  const TicketingSetupPage({
    super.key,
    required this.eventData,
  });

  @override
  State<TicketingSetupPage> createState() => _TicketingSetupPageState();
}

class _TicketingSetupPageState extends State<TicketingSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _ticketNameController = TextEditingController(text: 'General Admission');
  final _priceController = TextEditingController(text: '0');
  final _availabilityController = TextEditingController(text: '100');

  bool _enableEarlyBirdPricing = false;

  @override
  void initState() {
    super.initState();
    _ticketNameController.addListener(_updateState);
    _priceController.addListener(_updateState);
    _availabilityController.addListener(_updateState);
  }

  void _updateState() {
    setState(() {});
  }

  @override
  void dispose() {
    _ticketNameController.dispose();
    _priceController.dispose();
    _availabilityController.dispose();
    super.dispose();
  }

  double get _price {
    return double.tryParse(_priceController.text) ?? 0.0;
  }

  int get _availability {
    return int.tryParse(_availabilityController.text) ?? 0;
  }

  double get _potentialRevenue {
    return _price * _availability;
  }

  void _handleContinue() {
    if (_formKey.currentState!.validate()) {
      // Create updated event data with ticketing info
      final updatedEventData = EventCreationData(
        title: widget.eventData.title,
        description: widget.eventData.description,
        theme: widget.eventData.theme,
        startAt: widget.eventData.startAt,
        endAt: widget.eventData.endAt,
        location: widget.eventData.location,
        ticketName: _ticketNameController.text,
        price: _price,
        availability: _availability,
        coverImage: null,
        thumbnailImage: null,
      );
      
      // Navigate to next page (Media page - 3/4)
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => EventMediaPage(eventData: updatedEventData),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 16,
                left: 16,
                right: 16,
                bottom: 8,
              ),
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Color(0xFF0F1728),
                            size: 24,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Ticketing Setup',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF0F1728),
                            fontSize: 16,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            height: 1.75,
                          ),
                        ),
                      ),
                      Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.centerRight,
                        child: const Text(
                          '2/4',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Color(0xFF1E3A8A),
                            fontSize: 16,
                            fontFamily: 'Futura PT',
                            fontWeight: FontWeight.w400,
                            height: 1.50,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Progress Bar
                  Container(
                    width: double.infinity,
                    height: 6,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFEAECF0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          top: 0,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.50,
                            height: 6,
                            decoration: ShapeDecoration(
                              color: const Color(0xFF1E3A8A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                          width: 1,
                          color: Color(0xFFEAECF0),
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section Header with Add Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Expanded(
                              child: Text(
                                'Ticketing Setup',
                                style: TextStyle(
                                  color: Color(0xFF0A0A0A),
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                  height: 1.50,
                                  letterSpacing: -0.31,
                                ),
                              ),
                            ),
                            Container(
                              height: 32,
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 1,
                                    color: Colors.black.withValues(alpha: 0.10),
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: TextButton(
                                onPressed: () {
                                  // TODO: Add functionality to add more ticket types
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Add ticket type - Coming soon'),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 11,
                                    vertical: 6,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.add,
                                      size: 16,
                                      color: Color(0xFF0A0A0A),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Add Ticket Type',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Color(0xFF0A0A0A),
                                        fontSize: 14,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w500,
                                        height: 1.43,
                                        letterSpacing: -0.15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Ticket Name
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ticket Name *',
                              style: TextStyle(
                                color: Color(0xFF314157),
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                height: 1,
                                letterSpacing: -0.15,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              height: 44,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: ShapeDecoration(
                                color: const Color(0xFFF3F3F5),
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                    width: 1,
                                    color: Color(0xFFCAD5E2),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: TextFormField(
                                controller: _ticketNameController,
                                style: const TextStyle(
                                  color: Color(0xFF0A0A0A),
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  height: 1.50,
                                  letterSpacing: -0.31,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Ticket name is required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Price
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Price *',
                              style: TextStyle(
                                color: Color(0xFF314157),
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                height: 1,
                                letterSpacing: -0.15,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              height: 44,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: ShapeDecoration(
                                color: const Color(0xFFF3F3F5),
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                    width: 1,
                                    color: Color(0xFFCAD5E2),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Text(
                                    '\$',
                                    style: TextStyle(
                                      color: Color(0xFF45556C),
                                      fontSize: 16,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      height: 1.50,
                                      letterSpacing: -0.31,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _priceController,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                                      ],
                                      style: const TextStyle(
                                        color: Color(0xFF0A0A0A),
                                        fontSize: 16,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                        height: 1.50,
                                        letterSpacing: -0.31,
                                      ),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Price is required';
                                        }
                                        final price = double.tryParse(value);
                                        if (price == null || price < 0) {
                                          return 'Please enter a valid price';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Total Availability
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Availability *',
                              style: TextStyle(
                                color: Color(0xFF314157),
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                height: 1,
                                letterSpacing: -0.15,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              height: 44,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: ShapeDecoration(
                                color: const Color(0xFFF3F3F5),
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                    width: 1,
                                    color: Color(0xFFCAD5E2),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: TextFormField(
                                controller: _availabilityController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                style: const TextStyle(
                                  color: Color(0xFF0A0A0A),
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  height: 1.50,
                                  letterSpacing: -0.31,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Total availability is required';
                                  }
                                  final availability = int.tryParse(value);
                                  if (availability == null || availability <= 0) {
                                    return 'Please enter a valid number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Early Bird Pricing Checkbox
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(top: 17),
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1,
                                color: const Color(0xFFF0F4F9),
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: Checkbox(
                                  value: _enableEarlyBirdPricing,
                                  onChanged: (value) {
                                    setState(() {
                                      _enableEarlyBirdPricing = value ?? false;
                                    });
                                  },
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                  side: BorderSide(
                                    width: 1,
                                    color: Colors.black.withValues(alpha: 0.10),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  fillColor: WidgetStateProperty.resolveWith<Color>(
                                    (Set<WidgetState> states) {
                                      if (states.contains(WidgetState.selected)) {
                                        return const Color(0xFF1E3A8A);
                                      }
                                      return const Color(0xFFF3F3F5);
                                    },
                                  ),
                                  checkColor: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Enable Early Bird Pricing',
                                style: TextStyle(
                                  color: Color(0xFF314157),
                                  fontSize: 14,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                  height: 1,
                                  letterSpacing: -0.15,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Ticket Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: ShapeDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment(0.00, 0.00),
                              end: Alignment(1.00, 1.00),
                              colors: [Color(0xFFEEF5FE), Color(0xFFF8F9FB)],
                            ),
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                width: 1,
                                color: Color(0xFFDAEAFE),
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFF1B388E),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.confirmation_number,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _ticketNameController.text.isEmpty
                                            ? 'General Admission'
                                            : _ticketNameController.text,
                                        style: const TextStyle(
                                          color: Color(0xFF0E162B),
                                          fontSize: 16,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                          height: 1.50,
                                          letterSpacing: -0.31,
                                        ),
                                      ),
                                      Text(
                                        '$_availability available',
                                        style: const TextStyle(
                                          color: Color(0xFF45556C),
                                          fontSize: 14,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                          height: 1.43,
                                          letterSpacing: -0.15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Text(
                                '\$${_price.toStringAsFixed(2)}',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  color: Color(0xFF1B388E),
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  height: 1.50,
                                  letterSpacing: -0.31,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Summary Section
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: ShapeDecoration(
                            color: const Color(0xFFF8FAFC),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Summary',
                                style: TextStyle(
                                  color: Color(0xFF0E162B),
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  height: 1.50,
                                  letterSpacing: -0.31,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Total Capacity',
                                    style: TextStyle(
                                      color: Color(0xFF45556C),
                                      fontSize: 14,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      height: 1.43,
                                      letterSpacing: -0.15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$_availability tickets',
                                    style: const TextStyle(
                                      color: Color(0xFF0E162B),
                                      fontSize: 16,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      height: 1.50,
                                      letterSpacing: -0.31,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Potential Revenue',
                                    style: TextStyle(
                                      color: Color(0xFF45556C),
                                      fontSize: 14,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      height: 1.43,
                                      letterSpacing: -0.15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$${_potentialRevenue.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Color(0xFF0E162B),
                                      fontSize: 16,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      height: 1.50,
                                      letterSpacing: -0.31,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Bottom Button Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 1,
                      ),
                      child: const Text(
                        'Continue to Media',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          height: 1.50,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Bottom indicator (home indicator for iOS)
                  Container(
                    width: 134,
                    height: 5,
                    decoration: ShapeDecoration(
                      color: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

