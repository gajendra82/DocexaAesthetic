class patientget {
  String? status;
  Data? data;

  patientget({this.status, this.data});

  patientget.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  List<Patient>? patient;
  int? totalPatient;

  Data({this.patient, this.totalPatient});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['patient'] != null) {
      patient = <Patient>[];
      json['patient'].forEach((v) {
        patient!.add(Patient.fromJson(v));
      });
    }
    totalPatient = json['total_patient'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (this.patient != null) {
      data['patient'] = this.patient!.map((v) => v.toJson()).toList();
    }
    data['total_patient'] = this.totalPatient;
    return data;
  }
}

class Patient {
  int? patientId;
  String? patientName;
  String? email;
  String? mobileNo;
  int? age;
  int? gender;
  String? dob;
  int? visitType;
  String? registeredDate;
  String? lastAppointmentDate;

  Patient({
    this.patientId,
    this.patientName,
    this.email,
    this.mobileNo,
    this.age,
    this.gender,
    this.dob,
    this.visitType,
    this.registeredDate,
    this.lastAppointmentDate,
  });

  Patient.fromJson(Map<String, dynamic> json) {
    patientId = json['patient_id'];
    patientName = json['patient_name'];
    email = json['email'];
    mobileNo = json['mobile_no'];
    age = json['age'];
    gender = json['gender'];
    dob = json['dob'];
    visitType = json['visit_type'];
    registeredDate = json['registered_date'];
    lastAppointmentDate = json['last_appointment_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['patient_id'] = this.patientId;
    data['patient_name'] = this.patientName;
    data['email'] = this.email;
    data['mobile_no'] = this.mobileNo;
    data['age'] = this.age;
    data['gender'] = this.gender;
    data['dob'] = this.dob;
    data['visit_type'] = this.visitType;
    data['registered_date'] = this.registeredDate;
    data['last_appointment_date'] = this.lastAppointmentDate;
    return data;
  }
}
