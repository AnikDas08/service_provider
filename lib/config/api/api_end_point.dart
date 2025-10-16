class ApiEndPoint {
  static const baseUrl = "http://10.10.7.22:5000/api/v1/";
  static const imageUrl = "http://10.10.7.22:5000/";
  static const socketUrl = "http://10.10.7.22:5000/";

  static const signUp = "user/user";
  static const verifyEmail = "users/verify-email";
  static const category = "category";
  static const subCategory = "sub-category";
  static const verifyUser = "auth/verify-account";
  static const signIn = "auth/login";
  static const privacyPolicy = "settings/privacyPolicy";
  static const termsCondition = "settings/termsAndConditions";
  static const serviceProviderPolicy = "settings/providerUsagePolicy";
  static const scheduleProvider = "schedule";
  static const contracSupport = "contact-support";
  static const forgotPassword = "auth/forget-password";
  static const verifyOtp = "auth/verify-otp";
  static const provider = "provider";
  static const getProvider = "provider/my-provider";
  static const resetPassword = "auth/reset-password";
  static const myProvider = "provider/my-provider";
  static const changePassword = "auth/change-password";
  static const user = "user/profile";
  static const notifications = "notifications";
  static const chats = "chats";
  static const messages = "messages";
}
