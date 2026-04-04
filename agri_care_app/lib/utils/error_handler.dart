class ErrorHandler {
  static String getMessage(dynamic error) {
    final err = error.toString().toLowerCase();

    // Timeout
    if (err.contains("timeoutexception")) {
      return "Request timed out. Please try again later.";
    }

    // No Internet
    if (err.contains("socketexception")) {
      return "No internet connection. Please check your connection.";
    }

    // File too large
    if (err.contains("filetoolarge")) {
      return "File is too large. Maximum allowed size is 5MB.";
    }

    // Invalid file type
    if (err.contains("invalidfiletype")) {
      return "Invalid file format. Please upload JPG or PNG images.";
    }

    // Token / API limit reached
    if (err.contains("429") || err.contains("tokenlimit")) {
      return "Detection limit has been reached. Please try again later.";
    }

    // Server error
    if (err.contains("500")) {
      return "Server error. Please try again later.";
    }

    // Unknown error
    return "Something went wrong. Please try again.";
  }
}