class Createaccountresponse {
  final bool status;
  final String message;
  final dynamic data;

  Createaccountresponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory Createaccountresponse.fromJson(Map<String, dynamic> json) {
    return Createaccountresponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'], // can be null or a nested object
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data,
    };
  }
}
