const String PASSWORD_SHA_SALT = "irn65940wjv.rogm5iuh8402n434";

//Social Reporting
const String REPORT_REASON_SPAM = "SPAM";
const String REPORT_REASON_NUDITY = "NUDITY";
const String REPORT_REASON_HATE_SPEECH = "HATE_SPEECH";
const String REPORT_REASON_VIOLENCE = "VIOLENCE";
const String REPORT_REASON_SALE_OF_ILLEGAL_GOODS = "SALE_OF_ILLEGAL_GOODS";
const String REPORT_REASON_BULLYING = "BULLYING";
const String REPORT_REASON_INTELLECTUAL_PROPERTY_VIOLATION =
    "INTELLECTUAL_PROPERTY_VIOLATION";
const String REPORT_REASON_SUICIDE = "SUICIDE";
const String REPORT_REASON_EATING_DISORDERS = "EATING_DISORDERS";
const String REPORT_REASON_SCAM = "SCAM";
const String REPORT_REASON_FALSE_INFORMATION = "FALSE_INFORMATION";
const String REPORT_REASON_OTHER = "OTHER";

const String REPORT_REASON_SPAM_PROMPT = "It's spam";
const String REPORT_REASON_NUDITY_PROMPT = "Nudity or sexual activity";
const String REPORT_REASON_HATE_SPEECH_PROMPT = "Hate Speech or symbols";
const String REPORT_REASON_VIOLENCE_PROMPT =
    "Violence or dangerous organizations";
const String REPORT_REASON_SALE_OF_ILLEGAL_GOODS_PROMPT =
    "Sale of illegal or regulated goods";
const String REPORT_REASON_BULLYING_PROMPT = "Bullying or harrasment";
const String REPORT_REASON_INTELLECTUAL_PROPERTY_VIOLATION_PROMPT =
    "Intellectual property violation";
const String REPORT_REASON_SUICIDE_PROMPT = "Suicide or self-injury";
const String REPORT_REASON_EATING_DISORDERS_PROMPT = "Eating desorders";
const String REPORT_REASON_SCAM_PROMPT = "Scam or fraud";
const String REPORT_REASON_FALSE_INFORMATION_PROMPT = "False information";
const String REPORT_REASON_OTHER_PROMPT = "Other (Please specify)";

//City
const String CITY_JOHANNESBURG = "johannesburg";

//Login Errors
const String EMAIL_EXISTS = "EMAIL_EXISTS";
const String USERNAME_EXISTS = "USERNAME_EXISTS";
const String LOGIN_FAILED = "LOGIN_FAILED";

//Paystack Errors
const String INVALID_PURCHASE_REFERENCE = "INVALID_PURCHASE_REFERENCE";
const String TRANSACTION_NOT_SUCCESSFUL = "TRANSACTION_NOT_SUCCESSFUL";

//Prompts
const String EMAIL_EXISTS_PROMPT =
    "This email address is already in use. Please try a different email address.";
const String USERNAME_EXISTS_PROMPT =
    "This username is already in use. Please try a different username.";
const String LOGIN_FAILED_PROMPT =
    "The username or password you have entered is incorrect.";
const String NETWORK_ERROR_PROMPT =
    "Something went wrong. Please check your connection and try again.";
const String IMAGE_SIZE_ERROR_PROMPT =
    "The chosen image is too large. Please choose another file.";
const String UNKNOWN_ERROR_PROMPT =
    "An unknown error occured. Please check your connection and try again.";
const String CANNOT_LAUNCH_URL_PROMPT =
    "Sorry, we couldn't open that page. Please try again.";
const String NEW_PASSWORDS_ERROR_PROMPT =
    "Your new passwords do not match. Please check them again.";
const String INCORRECT_OLD_PASSWORD_ERROR_PROMPT =
    "Your old password is incorrect. Please try agian.";
const String ERROR_SENDING_MESSAGE =
    "There was a problem sending your message. Please try again.";

//Social
const String SOCIAL_POST_SUCCESS_TITLE = "Upload Successful";
const String SOCIAL_POST_SUCCESS_DESC = "Your post was uploaded successfully.";

const String SOCIAL_POST_ERROR_TITLE = "An Error Occurred";

//Messages
const String MESSAGE_TYPE_TEXT = "MESSAGE_TYPE_TEXT";
const String MESSAGE_TYPE_MEDIA = "MESSAGE_TYPE_MEDIA";
const String MESSAGE_TYPE_POST = "MESSAGE_TYPE_POST";

const String MESSAGE_STATUS_SENT = "MESSAGE_STATUS_SENT";
const String MESSAGE_STATUS_PENDING = "MESSAGE_STATUS_PENDING";
const String MESSAGE_STATUS_UPLOADING_IMAGE = "MESSAGE_STATUS_UPLOADING_IMAGE";
const String MESSAGE_STATUS_ERROR = "MESSAGE_STATUS_ERROR";

//Settings
const String NOTIFICATION_ALL_NEARBY = "NOTIFICATION_ALL_NEARBY";
const String NOTIFICATION_FAVOURITE_ONLY = "NOTIFICATION_FAVOURITE_ONLY";
const String NOTIFICATION_OFF = "NOTIFICATION_OFF";

const String NOTIFICATION_ALL_NEARBY_OPTION = "All Nearby Clubs";
const String NOTIFICATION_FAVOURITE_ONLY_OPTION = "Only Favourite Clubs";
const String NOTIFICATION_OFF_OPTION = "Off";

const String CHAT_NOTIFICATION_ON = "CHAT_NOTIFICATION_ON";
const String CHAT_NOTIFICATION_OFF = "CHAT_NOTIFICATION_OFF";

const String CHAT_NOTIFICATION_ON_OPTION = "On";
const String CHAT_NOTIFICATION_OFF_OPTION = "Off";

//Preference Keys
const String PREF_DEFAULT_CITY_LAT_KEY = "PREF_DEFAULT_CITY_LAT_KEY";
const String PREF_DEFAULT_CITY_LON_KEY = "PREF_DEFAULT_CITY_LON_KEY";
const String PREF_AUTH_TOKEN_KEY = "PREF_AUTH_TOKEN_KEY";
const String PREF_USER_ID_KEY = "PREF_USER_ID_KEY";
const String PREF_USERNAME_KEY = "PREF_USERNAME_KEY";
const String PREF_EMAIL_KEY = "PREF_EMAIL_KEY";
const String PREF_PROFILE_PIC_KEY = "PREF_PROFILE_PIC_KEY";
const String PREF_FCM_TOKEN_SAVED_KEY = "PREF_FCM_TOKEN_SAVED_KEY";
const String PREF_USER_MESSAGES_LOADED_KEY = "PREF_USER_MESSAGES_LOADED_KEY";
const String PREF_USER_CONVERSATIONS_LOADED_KEY =
    "PREF_USER_CONVERSATIONS_LOADED_KEY";
const String PREF_COVER_PIC_KEY = "PREF_COVER_PIC_KEY";
const String PREF_CITY_KEY = "PREF_CITY_KEY";
const String PREF_FAVOURITE_CLUBS_IDS_KEY = "PREF_FAVOURITE_CLUBS_IDS_KEY";
const String PREF_MUTED_CONVERSATIONS_IDS_KEY =
    "PREF_MUTED_CONVERSATIONS_IDS_KEY";
const String PREF_NOTIFICATION_SETTING_KEY = "PREF_NOTIFICATION_SETTING_KEY";
const String PREF_CHAT_NOTIFICATION_SETTING_KEY =
    "PREF_CHAT_NOTIFICATION_SETTING_KEY";
const String PREF_SOUND_ENABLED_KEY = "PREF_SOUND_ENABLED_KEY";
const String PREF_USER_FOLLOWERS_COUNT_KEY = "PREF_USER_FOLLOWERS_COUNT_KEY";

//Other
// const String API_HOST = "http://10.0.2.2:8080/api/v1"; //Emulator Tests
// const String API_HOST = "http://10.0.0.184:8080/api/v1"; //Personal Device Tests (IP of Laptop)
const String API_HOST = "https://13d0-2601-482-0-37f0-101-921f-ddbc-2f0c.ngrok.io/api/v1"; //ngrok
// const String API_HOST = "https://groovenation-test.herokuapp.com/api/v1"; //Heroku Tests

const String BASIC_ERROR_TITLE = "Something Went Wrong";
const String NEW_FOLLOWER_NOTIFICATION_TITLE = "You've gained a new follower";

//Links

const String TERMS_AND_CONDITIONS_LINK = "https://google.com";
const String PRIVACY_POLICY_LINK = "https://google.com";
const String GROOVENATION_WEBSITE_LINK = "https://google.com";

