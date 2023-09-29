import 'package:flutter/material.dart';
import 'package:noel_notes/component/icons/unicon_icons.dart';
import 'package:noel_notes/component/themes.dart';

enum SettingEvent {
  read,
  write,
  delete,
  add;
}

typedef Observer<T> = void Function(SettingsField<T> field, SettingEvent event);

class SettingsField<T> {
  T _value;
  SettingsField(this._value);
  Map<SettingEvent, List<Observer<T>>> observers =
      Map.fromEntries(SettingEvent.values.map((e) => MapEntry(e, [])));

  // add an observer to this field
  void addObserver(SettingEvent event,
      void Function(SettingsField<T> field, SettingEvent event) observer) {
    observers[event]!.add(observer);
  }

  // notify an event occured
  void on(SettingEvent event) {
    for (var element in observers[event]!) {
      element(this, event);
    }
  }

  T getValue() {
    on(SettingEvent.read);
    return _value;
  }

  void setValue(T val) {
    on(SettingEvent.write);
    this._value = val;
  }

  static SettingsField make(val) {
    return SettingsField(val);
  }
}

class RadioSetting<T extends Enum> extends SettingsField<Enum> {
  RadioSetting(T super.value);
  static RadioSetting make(val) {
    return RadioSetting(val);
  }
}

class StringSetting extends SettingsField<String> {
  StringSetting(super.value);
  static StringSetting make(val) {
    return StringSetting(val);
  }
}

enum Settings {
  theme(
    RadioSetting.make,
    Brightness,
    Brightness.values,
    Brightness.light,
    Unicon.abacus,
  ),
  accent(
    RadioSetting.make,
    Accent,
    Accent.values,
    Accent.peachPink,
    Unicon.adobe,
  ),
  editorTitle(
    StringSetting.make,
    String,
    null,
    "Testing",
    Unicon.pound_circle,
  );

  const Settings(
      this.klass, this.allowedType, this.allowedList, this.value, this.icon);

  final SettingsField Function(Object value) klass;
  final Type allowedType; // only allow said type
  final List? allowedList; // only allow certain things of said type
  final Object value;
  final IconData icon;

  // make the default settings
  static Map<String, SettingsField> makeDefault() {
    return Map.fromEntries(
      Settings.values.map(
        (e) => MapEntry(e.name, e.klass(e.value)),
      ),
    );
  }
}

class SettingsManager {
  Map<String, SettingsField> settings = Settings.makeDefault();

  SettingsManager(Map? json) {
    if (json != null) {
      for (final e in Settings.values) {
        if (json.containsKey(e.name)) {
          // try to parse the jsonified stuff
          settings[e.name]!.setValue(
            singleObjectFromJson(
              e.allowedType,
              e.allowedList,
              json[e.name],
              e.value,
            ),
          );
        }
      }
    }
  }

  /// This converts jsonified objects into [SettingsField] according to [Settings]
  Object singleObjectFromJson(
      Type allowedType, List? allowedList, Object input, Object def) {
    if (def is Enum) {
      input as int;
      assert(allowedList != null && allowedList.length > input);
      return allowedList![input];
    } else if (allowedType == String) {
      assert(allowedList == null || allowedList.contains(input as String));
      return input as String;
    } else {
      throw UnimplementedError(
        "singleObjectFromJson: Cannot rebuild $allowedType from $input which if a(n) ${input.runtimeType}",
      );
    }
  }

  Map toJson() {
    /// we dont need any hints since they are built into the [Settings]
    return settings.map(
      (key, value) => MapEntry(key, singleObjectToJson(value)),
    );
  }

  Object singleObjectToJson(Object input) {
    switch (input.runtimeType) {
      case RadioSetting:
        return (input as RadioSetting).getValue().index;
      case StringSetting:
        return (input as StringSetting).getValue();
      default:
        throw UnimplementedError(
            "singleObjectToJson: ${input.runtimeType} - $input");
    }
  }

  T getValue<T>(Settings setting) {
    assert(T == dynamic || setting.allowedType == T);
    return settings[setting.name]!.getValue() as T;
  }

  void setValue<T>(Settings setting, T value) {
    print("setValue: T: $T, setting: $setting, value: $value");
    assert(T == dynamic || setting.allowedType == T);
    settings[setting.name]!.setValue(value);
  }

  void addObserver(Settings setting, SettingEvent event, Observer observer) {
    settings[setting.name]!.addObserver(event, observer);
  }
}
