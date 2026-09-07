mixin ValidationMixin {
  String? phoneValidator(String? value, int phoneLength) {
    RegExp regExp = RegExp(r'^[+]*[(]?[0-9]{1,4}[)]?[-\s./0-9]*$');
    bool isMatched = value != null ? regExp.hasMatch(value) : false;

    if (value == null || value.isEmpty) {
      return 'Please enter your mobile number';
    } else if (value.length < phoneLength) {
      return 'Please enter a valid mobile number';
    } else if (isMatched) {
      return null;
    } else {
      return 'Please enter a valid mobile number';
    }
  }

  bool _isEmailValid(String? email) {
    Pattern pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern.toString());
    return email != null ? regex.hasMatch(email) : false;
  }

  String? emailValidator(String? email) {
    if (email?.isNotEmpty ?? false) {
      if (_isEmailValid(email)) {
        return null;
      } else {
        return 'Please enter a valid email address';
      }
    } else {
      return 'Please enter your email address';
    }
  }

  String? passwordValidator(String? password) {
    if (password == null || password.isEmpty) {
      return 'Please enter your password';
    }

    if (password.startsWith(' ')) {
      return 'No leading white spaces allowed.';
    }

    // Check if the password length is at least 8 characters
    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    // Check if the password contains at least one letter, one number, one symbol, and one capital letter
    RegExp letterRegex = RegExp(r'[a-z]');
    RegExp capitalRegex = RegExp(r'[A-Z]');
    RegExp numberRegex = RegExp(r'[0-9]');
    RegExp symbolRegex = RegExp(r'[!@#$%^&*()_+{}|:<>?~-]');

    if (!letterRegex.hasMatch(password)) {
      return 'Password must contain at least one letter';
    }
    if (!capitalRegex.hasMatch(password)) {
      return 'Password must contain at least one capital letter';
    }
    if (!numberRegex.hasMatch(password)) {
      return 'Password must contain at least one number';
    }
    if (!symbolRegex.hasMatch(password)) {
      return 'Password must contain at least one symbol';
    }

    // Return null if the password meets all requirements
    return null;
  }

  String? newPasswordValidator(String? password) {
    if (password == null || password.isEmpty) {
      return 'Please enter your password';
    }

    if (password.startsWith(' ')) {
      return 'No leading white spaces allowed.';
    }

    // Check if the password length is at least 8 characters
    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    // Check if the password contains at least one letter, one number, one symbol, and one capital letter
    RegExp letterRegex = RegExp(r'[a-z]');
    RegExp capitalRegex = RegExp(r'[A-Z]');
    RegExp numberRegex = RegExp(r'[0-9]');
    RegExp symbolRegex = RegExp(r'[!@#$%^&*()_+{}|:<>?~-]');

    if (!letterRegex.hasMatch(password)) {
      return 'Password must contain at least one letter';
    }
    if (!capitalRegex.hasMatch(password)) {
      return 'Password must contain at least one capital letter';
    }
    if (!numberRegex.hasMatch(password)) {
      return 'Password must contain at least one number';
    }
    if (!symbolRegex.hasMatch(password)) {
      return 'Password must contain at least one symbol';
    }

    // Return null if the password meets all requirements
    return null;
  }

  String? otpValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a OTP';
    } else if (value.length < 4) {
      return 'Please enter full OTP';
    }
    return null;
  }

  String? nameValidator(String? name) {
    final validCharacters = RegExp(r'^[a-zA-Z\s]+$');

    if (name != null) {
      if (name.isEmpty) {
        return 'Please enter your full name.';
      } else if (name.startsWith(' ')) {
        return 'No leading white spaces allowed.';
      } else if (name.contains('  ')) {
        return 'Only one space allowed after the name.';
      } else if (name.length <= 1) {
        return 'Full name must contain at least two characters.';
      } else if (!validCharacters.hasMatch(name)) {
        return 'Name should only be in alphabets';
      } else {
        return null;
      }
    } else {
      return 'Please enter your full name.';
    }
  }

  String? confirmPasswordValidatorForForgotPassword(String? value, String password) {
    if (value?.isNotEmpty ?? false) {
      if (password == value) {
        return null;
      }
      return 'New Password and Re-Enter Password doesn\'t \nmatch';
    } else {
      return 'Please Re-Enter New password';
    }
  }

  String? currentPassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Please enter your current password';
    }

    if (password.startsWith(' ')) {
      return 'No leading white spaces allowed.';
    }

    // Check if the password length is at least 8 characters
    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    // Check if the password contains at least one letter, one number, one symbol, and one capital letter
    RegExp letterRegex = RegExp(r'[a-z]');
    RegExp capitalRegex = RegExp(r'[A-Z]');
    RegExp numberRegex = RegExp(r'[0-9]');
    RegExp symbolRegex = RegExp(r'[!@#$%^&*()_+{}|:<>?~-]');

    if (!letterRegex.hasMatch(password)) {
      return 'Password must contain at least one letter';
    }
    if (!capitalRegex.hasMatch(password)) {
      return 'Password must contain at least one capital letter';
    }
    if (!numberRegex.hasMatch(password)) {
      return 'Password must contain at least one number';
    }
    if (!symbolRegex.hasMatch(password)) {
      return 'Password must contain at least one symbol';
    }

    // Return null if the password meets all requirements
    return null;
  }

  String? addressValidator(String? address) {
    final validCharacters = RegExp(r'^[a-zA-Z0-9\s,.-]+$');

    if (address != null) {
      if (address.isEmpty) {
        return 'Please enter your address.';
      } else if (address.startsWith(' ')) {
        return 'No leading white spaces allowed.';
      } else if (address.length < 5) {
        return 'Address must contain at least 5 characters.';
      } else if (!validCharacters.hasMatch(address)) {
        return 'Address contains invalid characters.';
      } else {
        return null;
      }
    } else {
      return 'Please enter your address.';
    }
  }
}
