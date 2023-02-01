class Employee_Leave_Histroy {
  String? leaveType;
  String? startDate;
  String? endDate;
  String? daysToLeave;
  String? employeeName;
  String? uid;
  String? status;
  String? leaveStartTimeStamp;
  String? leaveEndTimeStamp;

// receiving data
  Employee_Leave_Histroy({
    this.leaveType,
    this.startDate,
    this.endDate,
    this.daysToLeave,
    this.employeeName,
    this.uid,
    this.status,
    this.leaveStartTimeStamp,
    this.leaveEndTimeStamp,
  });
  factory Employee_Leave_Histroy.fromMap(map) {
    return Employee_Leave_Histroy(
        uid: map['uid'],
        leaveType: map['leaveType'],
        startDate: map['startDate'],
        endDate: map['endDate'],
        daysToLeave: map['daysToLeave'],
        employeeName: map['employeeName'],
        status: map['status'],
        leaveStartTimeStamp: map['leaveStartTimeStamp'],
        leaveEndTimeStamp: map['leaveEndTimeStamp']);
  }
// sending data
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'leaveType': leaveType,
      'startDate': startDate,
      'endDate': endDate,
      'dayToLeave': daysToLeave,
      'employeeName': employeeName,
      'status': status,
      'leaveStartTimeStamp': leaveStartTimeStamp,
      'leaveEndTimeStamp': leaveEndTimeStamp,
    };
  }
}
