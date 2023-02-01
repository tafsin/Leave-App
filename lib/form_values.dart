class FormValue {
  String? leaveType;
  String? startDate;
  String? endDate;
  String? daysToLeave;
  String? userEmail;
  String? employeeName;
  String? uid;
  String? remarks;
  String? status;

  DateTime? leaveStartDate;
  DateTime? leaveEndDate;
  Map? approverLists;
  List? approverListArray;
  int approveCount = 0;


// receiving data
  FormValue({
    this.leaveType,
    this.startDate,
    this.endDate,
    this.daysToLeave,
    this.userEmail,
    this.employeeName,
    this.uid,
    this.remarks,
    this.status,

    this.leaveEndDate,
    this.leaveStartDate,
    this.approverLists,
    this.approverListArray,
  });
  factory FormValue.fromMap(map) {
    return FormValue(
        uid: map['uid'],
        leaveType: map['leaveType'],
        startDate: map['startDate'],
        endDate: map['endDate'],
        daysToLeave: map['daysToLeave'],
        userEmail: map['userEmail'],
        employeeName: map['employeeName'],
        remarks: map['remarks'],
        leaveStartDate: map['leaveStart'],
        leaveEndDate: map['leaveEnd'],
        status: map['status'],
        approverLists: map['approverLists'],
        approverListArray: map['approverListArray'],
         );
  }
// sending data
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'leaveType': leaveType,
      'startDate': startDate,
      'endDate': endDate,
      'dayToLeave': daysToLeave,
      'userEmail': userEmail,
      'employeeName': employeeName,
      'remarks': remarks,
      'status': 'Pending',
      'leaveStart': leaveStartDate,
      'leaveEnd': leaveEndDate,
      'approverList': approverLists,
      'approverListArray':approverListArray,
      'approveCount': approveCount,
    };
  }
}
