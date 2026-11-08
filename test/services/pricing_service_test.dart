import 'package:faheng_api/services/pricing_service.dart';
import 'package:test/test.dart';

void main() {
  test('toCents avoids decimal errors', () {
    expect(toCents(1.20), 120);
    expect(toCents(1.10), 110);
    expect(toCents(0.95), 95);
  });

  test('no discount below 150 kg', () {
    final totals = calculateTotals(lineCents: [240, 5500], totalKg: 52);
    expect(totals.subtotalCents, 5740);
    expect(totals.discountCents, 0);
    expect(totals.totalCents, 5740);
  });

  test('10% discount at exactly 150 kg', () {
    final totals = calculateTotals(lineCents: [16500], totalKg: 150);
    expect(totals.subtotalCents, 16500);
    expect(totals.discountCents, 1650);
    expect(totals.totalCents, 14850);
  });

  test('no discount just under 150 kg', () {
    final totals = calculateTotals(lineCents: [16489], totalKg: 149.9);
    expect(totals.discountCents, 0);
  });

  test('empty cart is all zeros', () {
    final totals = calculateTotals(lineCents: [], totalKg: 0);
    expect(totals.subtotalCents, 0);
    expect(totals.discountCents, 0);
    expect(totals.totalCents, 0);
  });
}
