class CallModel {
  final String id;
  final String accountSid;
  final String apiVersion;
  final String applicationSid;
  final String callSid;
  final String callStatus;
  final String called;
  final String caller;
  final int dialCallDuration;
  final String dialCallSid;
  final String dialCallStatus;
  final String direction;
  final String from;
  final String to;
  final String phoneNumber;
  final int timestamp;
  final String type;

  CallModel(this.id, this.accountSid, this.apiVersion, this.applicationSid, this.callSid, this.callStatus, this.called, this.caller,
      this.dialCallDuration, this.dialCallSid, this.dialCallStatus, this.direction, this.from, this.to, this.phoneNumber, this.timestamp, this.type);

  factory CallModel.fromJson(String id, Map json) {
    return CallModel(
      id,
      json['AccountSid'] as String,
      json['ApiVersion'] as String,
      json['ApplicationSid'] as String,
      json['CallSid'] as String,
      json['CallStatus'] as String,
      json['Called'] as String,
      json['Caller'] as String? ?? '',
      int.parse(json['DialCallDuration'] as String? ?? '0'),
      json['DialCallSid'] as String,
      json['DialCallStatus'] as String,
      json['Direction'] as String,
      json['From'] as String,
      json['To'] as String,
      json['phoneNumber'] as String,
      json['timestamp'] as int,
      json['type'] as String,
    );
  }
}
