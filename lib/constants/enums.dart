enum AuthError{
  LOGIN_FAILED,
  EMAIL_EXISTS_ERROR,
  USERNAME_EXISTS_ERROR,
  NETWORK_ERROR,
  UNKNOWN_ERROR,
}

enum ClubHomeType {
  NEARBY,
  TOP,
  FAVOURITE
}

enum SocialHomeType {
  NEARBY,
  FOLLOWING,
  TRENDING,
  USER
}

enum SocialPostType {
  IMAGE,
  VIDEO
}

enum EventHomeType {
  UPCOMING,
  FAVOURITE
}

enum UserLocationStatus {
  FOUND,
  SERVICE_DISABLED,
  NOT_FOUND,
  UNKNOWN_ERROR,
  PERMISSION_NOT_GRANTED
}

enum AppError {
  INCORRECT_OLD_PASSWORD,
  IMAGE_SIZE_ERROR,
  NETWORK_ERROR,
  REQUEST_CANCELLED,
  UNKNOWN_ERROR,
  INVALID_PURCHASE_REFERENCE,
  TRANSACTION_NOT_SUCCESSFUL
}

enum UsernameInputStatus {
  CHECKING_USERNAME,
  USERNAME_AVAILABLE,
  USERNAME_UNAVAILABLE,
  NONE
}