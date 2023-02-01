class AllEmployeeLeave {
  int? leaveNum;
  int? leaveTakenNum;
  int? balanceLeave;
  int? sickLeaveTaken;
  String? employeeName;
  String? userEmail;
  String? uid;
  bool? isActive;

  var year = DateTime(DateTime.now().year + 1);

// receiving data
  AllEmployeeLeave(
      {this.leaveNum,
      this.userEmail,
      this.employeeName,
      this.leaveTakenNum,
      this.balanceLeave,
      this.sickLeaveTaken,
      this.uid,
      this.isActive});
  factory AllEmployeeLeave.fromMap(map) {
    return AllEmployeeLeave(
        uid: map['uid'],
        userEmail: map['employeeEmail'],
        employeeName: map['employeeName'],
        leaveNum: map['leaveEntitled'],
        leaveTakenNum: map['leaveTakenNum'],
        sickLeaveTaken: map['sickLeaveTakenNum'],
        balanceLeave: map['balanceLeave'],
        isActive: map['isActive']);
  }
// sending data
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'employeeEmail': userEmail,
      'employeeName': employeeName,
      'leaveEntitled': leaveNum,
      'leaveTakenNum': leaveTakenNum,
      'sickLeaveTakenNum': sickLeaveTaken,
      'balanceLeave': balanceLeave,
      'isActive': isActive,
      'year': year,
    };
  }
}
