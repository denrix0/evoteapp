class ValidationResult {
  List errors;
  Map data;

  ValidationResult(this.errors, this.data);
}

class FieldValidations {
  static ValidationResult validateIpAddress(String _serverField) {
    List<String> _errorList = [];
    String? _serverIP;
    int _serverPort = 5000;

    RegExp _ipReg = RegExp(
        r'^(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))\.(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))\.(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))\.(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))$');

    bool validIp(String _ip) => _ipReg.hasMatch(_ip);

    if (_serverField != "") {
      if (':'.allMatches(_serverField).length == 1) {
        List _ipPort = _serverField.split(':');

        if (validIp(_ipPort[0])) {
          _serverIP = _ipPort[0];
        } else {
          _errorList.add("Invalid IP address");
        }

        if (_serverPort >= 0 && _serverPort <= 65535) {
          _serverPort = _ipPort[1];
        } else {
          _errorList.add("Invalid Port");
        }
      } else if (':'.allMatches(_serverField).isEmpty) {
        if (validIp(_serverField)) {
          _serverIP = _serverField;
        } else {
          _errorList.add("Invalid IP address");
        }
      } else {
        _errorList.add("Invalid Server address format");
      }
    } else {
      _errorList.add("Server address field is empty");
    }

    return ValidationResult(
        _errorList, {"serverIP": _serverIP, "serverPort": _serverPort});
  }

  static ValidationResult validateIDAndPIN(String _id, String _pin) {
    List _errorList = [];

    if (_id != '') {
      _id.replaceAll(' ', '');

      if (!RegExp(r'[0-9]+').hasMatch(_id)) {
        _errorList.add("Invalid ID");
      }
    } else {
      _errorList.add("ID field must not be empty");
    }

    // Validate PIN
    if (_pin != '') {
      _pin.replaceAll(' ', '');

      if (_pin.length < 8) {
        _errorList.add("Pin must be longer than 8 characters");
      }
    }

    return ValidationResult(_errorList, {"id": _id, "pin": _pin});
  }

  static ValidationResult validateOtp(String _otp) {
    List _errorList = [];

    if (_otp != '') {
      _otp.replaceAll(' ', '');

      if (_otp.length != 6) {
        _errorList.add('The OTP should be 6 digits long.');
      }
      if (!RegExp(r'[0-9]+').hasMatch(_otp)) {
        _errorList.add("The OTP should only consist of digits");
      }
    } else {
      _errorList.add("Field is empty");
    }

    return ValidationResult(_errorList, {"otp": _otp});
  }

  static ValidationResult validateUID(String _uid) {
    List _errorList = [];

    if (_uid != '') {
      _uid.replaceAll(' ', '');

      if (!RegExp(r'^[A-Za-z0-9_.]+$').hasMatch(_uid)) {
        _errorList.add("This seems invalid");
      }
    } else {
      _errorList.add("Field is empty");
    }

    return ValidationResult(_errorList, {'uid': _uid});
  }
}
