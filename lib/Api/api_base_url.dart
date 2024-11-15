class ApiConstants {
  static const String baseURL =
      "https://derejavrs2.azurewebsites.net/api/";
  static const String loginEndpoint = "Account/Employerlogin";
  static const String registeredEmployeesByEmployer =
      "Account/RegisteredEmployeesByEmployeer";
  static const String qrScanEndpoint = "Account/EmployeeRegister";
  static const String searchEndpoint =
      "Account/SearchRegisteredEmployeesByEmployeer";

  static const String totalCounts = "Account/TotalEventData";

  static String getLoginUrl() => baseURL + loginEndpoint;
  static String getRegisteredEmployeesUrl(String employerId) =>
      "$baseURL$registeredEmployeesByEmployer/$employerId";
  static String getSearchEmployeesUrl(String employerId) =>
      "$baseURL$searchEndpoint/$employerId";
  static String postQrScanDataUrl() => baseURL + qrScanEndpoint;
    static String getTotalCount() => baseURL + totalCounts;
}
