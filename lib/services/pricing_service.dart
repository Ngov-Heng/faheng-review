/// Total weight (kg) from which the bulk discount applies.
const bulkThresholdKg = 150;

/// Bulk discount, in percent of the subtotal.
const bulkDiscountPercent = 10;

/// Converts a price in dollars (like 1.20) to whole cents (120).
int toCents(num dollars) => (dollars * 100).round();

/// The money part of a cart, all in cents.
class CartTotals {
  /// Creates the totals.
  const CartTotals({
    required this.subtotalCents,
    required this.discountCents,
    required this.totalCents,
  });

  /// Sum of all line prices before the discount.
  final int subtotalCents;

  /// Bulk discount taken off the subtotal (0 when not eligible).
  final int discountCents;

  /// What the customer pays: subtotal minus discount.
  final int totalCents;
}

/// Works out subtotal, bulk discount and total for a cart.
CartTotals calculateTotals({
  required List<int> lineCents,
  required num totalKg,
}) {
  final subtotal = lineCents.fold<int>(0, (sum, cents) => sum + cents);
  final discount = totalKg >= bulkThresholdKg
      ? (subtotal * bulkDiscountPercent / 100).round()
      : 0;
  return CartTotals(
    subtotalCents: subtotal,
    discountCents: discount,
    totalCents: subtotal - discount,
  );
}
