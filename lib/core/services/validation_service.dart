class ValidationService {
  // Email validation
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // Password validation
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 6) {
      return 'Password must be at least 6 characters long';
    }

    return null;
  }

  // Name validation
  static String? validateName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Name is required';
    }

    if (name.trim().length < 2) {
      return 'Name must be at least 2 characters long';
    }

    return null;
  }

  // Phone validation
  static String? validatePhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      return 'Phone number is required';
    }

    final phoneRegex = RegExp(r'^[0-9+\-\s\(\)]{10,15}$');
    if (!phoneRegex.hasMatch(phone.trim())) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  // Item name validation
  static String? validateItemName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Item name is required';
    }

    if (name.trim().length < 2) {
      return 'Item name must be at least 2 characters long';
    }

    return null;
  }

  // Price validation
  static String? validatePrice(String? price) {
    if (price == null || price.trim().isEmpty) {
      return 'Price is required';
    }

    final priceValue = double.tryParse(price);
    if (priceValue == null) {
      return 'Please enter a valid price';
    }

    if (priceValue < 0) {
      return 'Price cannot be negative';
    }

    return null;
  }

  // Stock validation
  static String? validateStock(String? stock) {
    if (stock == null || stock.trim().isEmpty) {
      return 'Stock quantity is required';
    }

    final stockValue = int.tryParse(stock);
    if (stockValue == null) {
      return 'Please enter a valid stock quantity';
    }

    if (stockValue < 0) {
      return 'Stock quantity cannot be negative';
    }

    return null;
  }

  // GST percentage validation
  static String? validateGstPercentage(String? gst) {
    if (gst == null || gst.trim().isEmpty) {
      return null; // GST is optional
    }

    final gstValue = double.tryParse(gst);
    if (gstValue == null) {
      return 'Please enter a valid GST percentage';
    }

    if (gstValue < 0 || gstValue > 100) {
      return 'GST percentage must be between 0 and 100';
    }

    return null;
  }

  // Amount validation
  static String? validateAmount(String? amount) {
    if (amount == null || amount.trim().isEmpty) {
      return 'Amount is required';
    }

    final amountValue = double.tryParse(amount);
    if (amountValue == null) {
      return 'Please enter a valid amount';
    }

    if (amountValue <= 0) {
      return 'Amount must be greater than 0';
    }

    return null;
  }

  // Category validation
  static String? validateCategory(String? category) {
    if (category == null || category.trim().isEmpty) {
      return 'Category is required';
    }

    return null;
  }

  // Company name validation
  static String? validateCompanyName(String? companyName) {
    if (companyName == null || companyName.trim().isEmpty) {
      return 'Company name is required';
    }

    if (companyName.trim().length < 2) {
      return 'Company name must be at least 2 characters long';
    }

    return null;
  }

  // GST number validation
  static String? validateGstNumber(String? gstNumber) {
    if (gstNumber == null || gstNumber.trim().isEmpty) {
      return null; // GST number is optional
    }

    final gstRegex = RegExp(
      r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$',
    );
    if (!gstRegex.hasMatch(gstNumber.trim())) {
      return 'Please enter a valid GST number';
    }

    return null;
  }

  // PAN number validation
  static String? validatePanNumber(String? panNumber) {
    if (panNumber == null || panNumber.trim().isEmpty) {
      return null; // PAN number is optional
    }

    final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
    if (!panRegex.hasMatch(panNumber.trim())) {
      return 'Please enter a valid PAN number';
    }

    return null;
  }

  // Description validation
  static String? validateDescription(String? description) {
    if (description == null || description.trim().isEmpty) {
      return null; // Description is optional
    }

    if (description.trim().length > 500) {
      return 'Description cannot exceed 500 characters';
    }

    return null;
  }

  // SKU validation
  static String? validateSku(String? sku) {
    if (sku == null || sku.trim().isEmpty) {
      return null; // SKU is optional
    }

    if (sku.trim().length < 3) {
      return 'SKU must be at least 3 characters long';
    }

    return null;
  }

  // Barcode validation
  static String? validateBarcode(String? barcode) {
    if (barcode == null || barcode.trim().isEmpty) {
      return null; // Barcode is optional
    }

    if (barcode.trim().length < 8) {
      return 'Barcode must be at least 8 characters long';
    }

    return null;
  }

  // OTP validation
  static String? validateOtp(String? otp) {
    if (otp == null || otp.trim().isEmpty) {
      return 'OTP is required';
    }

    if (otp.trim().length != 6) {
      return 'OTP must be 6 digits';
    }

    final otpRegex = RegExp(r'^[0-9]{6}$');
    if (!otpRegex.hasMatch(otp.trim())) {
      return 'Please enter a valid 6-digit OTP';
    }

    return null;
  }

  // Reference number validation
  static String? validateReferenceNumber(String? referenceNumber) {
    if (referenceNumber == null || referenceNumber.trim().isEmpty) {
      return null; // Reference number is optional
    }

    if (referenceNumber.trim().length < 3) {
      return 'Reference number must be at least 3 characters long';
    }

    return null;
  }

  // Notes validation
  static String? validateNotes(String? notes) {
    if (notes == null || notes.trim().isEmpty) {
      return null; // Notes are optional
    }

    if (notes.trim().length > 1000) {
      return 'Notes cannot exceed 1000 characters';
    }

    return null;
  }

  // Date validation
  static String? validateDate(DateTime? date) {
    if (date == null) {
      return 'Date is required';
    }

    final now = DateTime.now();
    if (date.isAfter(now)) {
      return 'Date cannot be in the future';
    }

    return null;
  }

  // Future date validation (for orders, etc.)
  static String? validateFutureDate(DateTime? date) {
    if (date == null) {
      return 'Date is required';
    }

    return null;
  }
}
