class Loginresponse {
  String? status;
  Doctor? doctor;

  Loginresponse({this.status, this.doctor});

  Loginresponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    doctor =
        json['doctor'] != null ? new Doctor.fromJson(json['doctor']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.doctor != null) {
      data['doctor'] = this.doctor!.toJson();
    }
    return data;
  }
}

class Doctor {
  int? esteblishmentId;
  int? esteblishmentUserMapId;
  int? medicalUserId;
  String? handle;
  String? firstName;
  String? lastName;
  String? mobileNo;
  String? doctorMrNo;
  int? doctorMrState;
  String? doctorMrYear;
  Null? medicalCertificateUrl;
  Null? letterHeadCopy;
  String? city;
  Null? cityId;
  String? state;
  Null? stateId;
  Null? address;
  Null? isVaccine;
  List<Clinic>? clinic;
  List<SpecialityId>? specialityId;
  int? fee;
  int? unsubscribeFlag;
  String? profilePicture;
  int? roleId;

  Doctor(
      {this.esteblishmentId,
      this.esteblishmentUserMapId,
      this.medicalUserId,
      this.handle,
      this.firstName,
      this.lastName,
      this.mobileNo,
      this.doctorMrNo,
      this.doctorMrState,
      this.doctorMrYear,
      this.medicalCertificateUrl,
      this.letterHeadCopy,
      this.city,
      this.cityId,
      this.state,
      this.stateId,
      this.address,
      this.isVaccine,
      this.clinic,
      this.specialityId,
      this.fee,
      this.unsubscribeFlag,
      this.profilePicture,
      this.roleId});

  Doctor.fromJson(Map<String, dynamic> json) {
    esteblishmentId = json['esteblishment_id'];
    esteblishmentUserMapId = json['esteblishment_user_map_id'];
    medicalUserId = json['medical_user_id'];
    handle = json['handle'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    mobileNo = json['mobile_no'];
    doctorMrNo = json['doctor_mr_no'];
    doctorMrState = json['doctor_mr_state'];
    doctorMrYear = json['doctor_mr_year'];
    medicalCertificateUrl = json['medical_certificate_url'];
    letterHeadCopy = json['letter_head_copy'];
    city = json['city'];
    cityId = json['city_id'];
    state = json['state'];
    stateId = json['state_id'];
    address = json['address'];
    isVaccine = json['is_vaccine'];
    if (json['clinic'] != null) {
      clinic = <Clinic>[];
      json['clinic'].forEach((v) {
        clinic!.add(new Clinic.fromJson(v));
      });
    }
    if (json['speciality_id'] != null) {
      specialityId = <SpecialityId>[];
      json['speciality_id'].forEach((v) {
        specialityId!.add(new SpecialityId.fromJson(v));
      });
    }
    fee = json['fee'];
    unsubscribeFlag = json['unsubscribe_flag'];
    profilePicture = json['profilePicture'];
    roleId = json['role_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['esteblishment_id'] = this.esteblishmentId;
    data['esteblishment_user_map_id'] = this.esteblishmentUserMapId;
    data['medical_user_id'] = this.medicalUserId;
    data['handle'] = this.handle;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['mobile_no'] = this.mobileNo;
    data['doctor_mr_no'] = this.doctorMrNo;
    data['doctor_mr_state'] = this.doctorMrState;
    data['doctor_mr_year'] = this.doctorMrYear;
    data['medical_certificate_url'] = this.medicalCertificateUrl;
    data['letter_head_copy'] = this.letterHeadCopy;
    data['city'] = this.city;
    data['city_id'] = this.cityId;
    data['state'] = this.state;
    data['state_id'] = this.stateId;
    data['address'] = this.address;
    data['is_vaccine'] = this.isVaccine;
    if (this.clinic != null) {
      data['clinic'] = this.clinic!.map((v) => v.toJson()).toList();
    }
    if (this.specialityId != null) {
      data['speciality_id'] =
          this.specialityId!.map((v) => v.toJson()).toList();
    }
    data['fee'] = this.fee;
    data['unsubscribe_flag'] = this.unsubscribeFlag;
    data['profilePicture'] = this.profilePicture;
    data['role_id'] = this.roleId;
    return data;
  }
}

class Clinic {
  int? id;
  int? userMapId;
  String? clinicName;
  String? address;
  String? city;
  String? pincode;
  String? lat;
  String? long;
  int? isprimary;
  int? isenable;
  String? contactPerson;
  String? contactNo;
  Null? website;
  String? createdAt;
  String? updatedAt;
  String? state;
  String? clinicImages;
  int? isAggrement;
  int? isupdateview;

  Clinic(
      {this.id,
      this.userMapId,
      this.clinicName,
      this.address,
      this.city,
      this.pincode,
      this.lat,
      this.long,
      this.isprimary,
      this.isenable,
      this.contactPerson,
      this.contactNo,
      this.website,
      this.createdAt,
      this.updatedAt,
      this.state,
      this.clinicImages,
      this.isAggrement,
      this.isupdateview});

  Clinic.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userMapId = json['user_map_id'];
    clinicName = json['clinic_name'];
    address = json['address'];
    city = json['city'];
    pincode = json['pincode'];
    lat = json['lat'];
    long = json['long'];
    isprimary = json['isprimary'];
    isenable = json['isenable'];
    contactPerson = json['contact_person'];
    contactNo = json['contact_no'];
    website = json['website'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    state = json['state'];
    clinicImages = json['clinic_images'];
    isAggrement = json['is_aggrement'];
    isupdateview = json['isupdateview'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_map_id'] = this.userMapId;
    data['clinic_name'] = this.clinicName;
    data['address'] = this.address;
    data['city'] = this.city;
    data['pincode'] = this.pincode;
    data['lat'] = this.lat;
    data['long'] = this.long;
    data['isprimary'] = this.isprimary;
    data['isenable'] = this.isenable;
    data['contact_person'] = this.contactPerson;
    data['contact_no'] = this.contactNo;
    data['website'] = this.website;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['state'] = this.state;
    data['clinic_images'] = this.clinicImages;
    data['is_aggrement'] = this.isAggrement;
    data['isupdateview'] = this.isupdateview;
    return data;
  }
}

class SpecialityId {
  int? specialityId;
  String? specialityName;
  int? createdBy;
  String? createdDate;
  Null? updatedBy;
  Null? updatedDate;
  Null? deletedBy;
  Null? deletedDate;

  SpecialityId(
      {this.specialityId,
      this.specialityName,
      this.createdBy,
      this.createdDate,
      this.updatedBy,
      this.updatedDate,
      this.deletedBy,
      this.deletedDate});

  SpecialityId.fromJson(Map<String, dynamic> json) {
    specialityId = json['speciality_id'];
    specialityName = json['speciality_name'];
    createdBy = json['created_by'];
    createdDate = json['created_date'];
    updatedBy = json['updated_by'];
    updatedDate = json['updated_date'];
    deletedBy = json['deleted_by'];
    deletedDate = json['deleted_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['speciality_id'] = this.specialityId;
    data['speciality_name'] = this.specialityName;
    data['created_by'] = this.createdBy;
    data['created_date'] = this.createdDate;
    data['updated_by'] = this.updatedBy;
    data['updated_date'] = this.updatedDate;
    data['deleted_by'] = this.deletedBy;
    data['deleted_date'] = this.deletedDate;
    return data;
  }
}
