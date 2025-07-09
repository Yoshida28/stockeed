import 'package:intl/intl.dart';
import 'package:stocked/core/services/config_service.dart';

class UtilityService {
  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    symbol: '₹',
    decimalDigits: 2,
  );

  static final NumberFormat _numberFormatter = NumberFormat('#,##0');
  static final NumberFormat _decimalFormatter = NumberFormat('#,##0.00');
  static final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');
  static final DateFormat _timeFormatter = DateFormat('HH:mm');
  static final DateFormat _dateTimeFormatter = DateFormat('dd/MM/yyyy HH:mm');

  // Currency formatting
  static String formatCurrency(double amount) {
    try {
      final currencySymbol = ConfigService.get<String>(
        'currency_symbol',
        defaultValue: '₹',
      );
      return NumberFormat.currency(
        symbol: currencySymbol,
        decimalDigits: 2,
      ).format(amount);
    } catch (e) {
      return _currencyFormatter.format(amount);
    }
  }

  // Number formatting
  static String formatNumber(int number) {
    return _numberFormatter.format(number);
  }

  // Decimal formatting
  static String formatDecimal(double number) {
    return _decimalFormatter.format(number);
  }

  // Date formatting
  static String formatDate(DateTime? date) {
    if (date == null) return 'N/A';

    try {
      final dateFormat = ConfigService.get<String>(
        'date_format',
        defaultValue: 'dd/MM/yyyy',
      );
      return DateFormat(dateFormat).format(date);
    } catch (e) {
      return _dateFormatter.format(date);
    }
  }

  // Time formatting
  static String formatTime(DateTime? time) {
    if (time == null) return 'N/A';

    try {
      final timeFormat = ConfigService.get<String>(
        'time_format',
        defaultValue: 'HH:mm',
      );
      return DateFormat(timeFormat).format(time);
    } catch (e) {
      return _timeFormatter.format(time);
    }
  }

  // DateTime formatting
  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return _dateTimeFormatter.format(dateTime);
  }

  // Generate unique ID
  static String generateUniqueId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'ID$timestamp$random';
  }

  // Generate order number
  static String generateOrderNumber() {
    final now = DateTime.now();
    final year = now.year.toString().substring(2);
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final random = (now.millisecondsSinceEpoch % 1000).toString().padLeft(
      3,
      '0',
    );
    return 'ORD$year$month$day$random';
  }

  // Generate voucher number
  static String generateVoucherNumber() {
    final now = DateTime.now();
    final year = now.year.toString().substring(2);
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final random = (now.millisecondsSinceEpoch % 1000).toString().padLeft(
      3,
      '0',
    );
    return 'VCH$year$month$day$random';
  }

  // Generate payment number
  static String generatePaymentNumber() {
    final now = DateTime.now();
    final year = now.year.toString().substring(2);
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final random = (now.millisecondsSinceEpoch % 1000).toString().padLeft(
      3,
      '0',
    );
    return 'PAY$year$month$day$random';
  }

  // Generate expense number
  static String generateExpenseNumber() {
    final now = DateTime.now();
    final year = now.year.toString().substring(2);
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final random = (now.millisecondsSinceEpoch % 1000).toString().padLeft(
      3,
      '0',
    );
    return 'EXP$year$month$day$random';
  }

  // Calculate GST amount
  static double calculateGstAmount(double baseAmount, double gstPercentage) {
    return (baseAmount * gstPercentage) / 100;
  }

  // Calculate net amount (base + GST)
  static double calculateNetAmount(double baseAmount, double gstPercentage) {
    return baseAmount + calculateGstAmount(baseAmount, gstPercentage);
  }

  // Calculate total amount for multiple items
  static double calculateTotalAmount(List<Map<String, dynamic>> items) {
    double total = 0;
    for (final item in items) {
      final quantity = item['quantity'] ?? 0;
      final unitPrice = item['unitPrice'] ?? 0.0;
      total += quantity * unitPrice;
    }
    return total;
  }

  // Calculate total GST for multiple items
  static double calculateTotalGst(List<Map<String, dynamic>> items) {
    double totalGst = 0;
    for (final item in items) {
      final quantity = item['quantity'] ?? 0;
      final unitPrice = item['unitPrice'] ?? 0.0;
      final gstPercentage = item['gstPercentage'] ?? 0.0;
      totalGst += calculateGstAmount(quantity * unitPrice, gstPercentage);
    }
    return totalGst;
  }

  // Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // Validate file size
  static bool isValidFileSize(int bytes) {
    try {
      final maxSize = ConfigService.get<int>(
        'max_file_size_mb',
        defaultValue: 10,
      );
      final maxBytes = maxSize * 1024 * 1024;
      return bytes <= maxBytes;
    } catch (e) {
      return bytes <= 10 * 1024 * 1024; // Default 10MB
    }
  }

  // Get file extension
  static String getFileExtension(String fileName) {
    final parts = fileName.split('.');
    if (parts.length > 1) {
      return parts.last.toLowerCase();
    }
    return '';
  }

  // Validate file type
  static bool isValidFileType(String fileName, List<String> allowedExtensions) {
    final extension = getFileExtension(fileName);
    return allowedExtensions.contains(extension);
  }

  // Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // Title case
  static String titleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }

  // Truncate text
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // Get initials from name
  static String getInitials(String name) {
    if (name.isEmpty) return '';
    final words = name.trim().split(' ');
    if (words.length == 1) {
      return words[0][0].toUpperCase();
    }
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  // Check if string is numeric
  static bool isNumeric(String text) {
    return double.tryParse(text) != null;
  }

  // Check if string is integer
  static bool isInteger(String text) {
    return int.tryParse(text) != null;
  }

  // Get relative time
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  // Get days between dates
  static int getDaysBetween(DateTime start, DateTime end) {
    return end.difference(start).inDays;
  }

  // Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Check if date is this week
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  // Check if date is this month
  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }
}
