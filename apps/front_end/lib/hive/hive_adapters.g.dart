// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_adapters.dart';

// **************************************************************************
// AdaptersGenerator
// **************************************************************************

class ServerAdapter extends TypeAdapter<Server> {
  @override
  final typeId = 0;

  @override
  Server read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Server(
      id: fields[0] as String,
      name: fields[1] as String,
      password: fields[2] as String,
      address: fields[3] as String,
      port: (fields[4] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, Server obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.password)
      ..writeByte(3)
      ..write(obj.address)
      ..writeByte(4)
      ..write(obj.port);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServerAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

class MessageAdapter extends TypeAdapter<Message> {
  @override
  final typeId = 1;

  @override
  Message read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Message(
      id: fields[0] as String,
      body: fields[2] as String,
      sender: fields[3] as Sender,
      serverId: fields[1] as String,
      sortKey: fields[4] == null ? 0 : (fields[4] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, Message obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.serverId)
      ..writeByte(2)
      ..write(obj.body)
      ..writeByte(3)
      ..write(obj.sender)
      ..writeByte(4)
      ..write(obj.sortKey);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

class SenderAdapter extends TypeAdapter<Sender> {
  @override
  final typeId = 2;

  @override
  Sender read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Sender.client;
      case 1:
        return Sender.server;
      default:
        return Sender.client;
    }
  }

  @override
  void write(BinaryWriter writer, Sender obj) {
    switch (obj) {
      case Sender.client:
        writer.writeByte(0);
      case Sender.server:
        writer.writeByte(1);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SenderAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

class SavedMessageAdapter extends TypeAdapter<SavedMessage> {
  @override
  final typeId = 3;

  @override
  SavedMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedMessage(
      id: fields[0] as String,
      serverId: fields[1] as String,
      body: fields[2] as String,
      name: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SavedMessage obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.serverId)
      ..writeByte(2)
      ..write(obj.body)
      ..writeByte(3)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedMessageAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
