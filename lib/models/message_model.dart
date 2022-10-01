class MessageModel {
  final String id;
  final String body;
  final String from;
  final String to;
  final int timestamp;

  MessageModel(this.id, this.body, this.from, this.to, this.timestamp);

  factory MessageModel.fromJson(String id, Map json) {
    return MessageModel(
      id,
      json['Body'] as String,
      json['From'] as String,
      json['To'] as String,
      json['timestamp'] as int,
    );
  }
}

