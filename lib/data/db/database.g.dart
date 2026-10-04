// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SettingsRowsTable extends SettingsRows
    with TableInfo<$SettingsRowsTable, SettingsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Currency, String> currency =
      GeneratedColumn<String>(
        'currency',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Currency>($SettingsRowsTable.$convertercurrency);
  @override
  late final GeneratedColumnWithTypeConverter<PayFrequency, String>
  payFrequency = GeneratedColumn<String>(
    'pay_frequency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<PayFrequency>($SettingsRowsTable.$converterpayFrequency);
  @override
  late final GeneratedColumnWithTypeConverter<LocalDate, String> nextPayday =
      GeneratedColumn<String>(
        'next_payday',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LocalDate>($SettingsRowsTable.$converternextPayday);
  @override
  late final GeneratedColumnWithTypeConverter<IncomeType, String> incomeType =
      GeneratedColumn<String>(
        'income_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<IncomeType>($SettingsRowsTable.$converterincomeType);
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hourlyRateCentsMeta = const VerificationMeta(
    'hourlyRateCents',
  );
  @override
  late final GeneratedColumn<int> hourlyRateCents = GeneratedColumn<int>(
    'hourly_rate_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weekStartsOnMeta = const VerificationMeta(
    'weekStartsOn',
  );
  @override
  late final GeneratedColumn<int> weekStartsOn = GeneratedColumn<int>(
    'week_starts_on',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(DateTime.sunday),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ThemePreference, String> theme =
      GeneratedColumn<String>(
        'theme',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ThemePreference>($SettingsRowsTable.$convertertheme);
  static const VerificationMeta _appLockEnabledMeta = const VerificationMeta(
    'appLockEnabled',
  );
  @override
  late final GeneratedColumn<bool> appLockEnabled = GeneratedColumn<bool>(
    'app_lock_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("app_lock_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<OverspendStrategy, String>
  overspendStrategy =
      GeneratedColumn<String>(
        'overspend_strategy',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<OverspendStrategy>(
        $SettingsRowsTable.$converteroverspendStrategy,
      );
  static const VerificationMeta _onboardedMeta = const VerificationMeta(
    'onboarded',
  );
  @override
  late final GeneratedColumn<bool> onboarded = GeneratedColumn<bool>(
    'onboarded',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("onboarded" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<LocalDate?, String> lastBackupOn =
      GeneratedColumn<String>(
        'last_backup_on',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<LocalDate?>($SettingsRowsTable.$converterlastBackupOnn);
  static const VerificationMeta _remindLogSpendsMeta = const VerificationMeta(
    'remindLogSpends',
  );
  @override
  late final GeneratedColumn<bool> remindLogSpends = GeneratedColumn<bool>(
    'remind_log_spends',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("remind_log_spends" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _remindLogAtMeta = const VerificationMeta(
    'remindLogAt',
  );
  @override
  late final GeneratedColumn<int> remindLogAt = GeneratedColumn<int>(
    'remind_log_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1230),
  );
  static const VerificationMeta _remindBillsMeta = const VerificationMeta(
    'remindBills',
  );
  @override
  late final GeneratedColumn<bool> remindBills = GeneratedColumn<bool>(
    'remind_bills',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("remind_bills" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _remindLatePauseMeta = const VerificationMeta(
    'remindLatePause',
  );
  @override
  late final GeneratedColumn<bool> remindLatePause = GeneratedColumn<bool>(
    'remind_late_pause',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("remind_late_pause" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _remindRecapsMeta = const VerificationMeta(
    'remindRecaps',
  );
  @override
  late final GeneratedColumn<bool> remindRecaps = GeneratedColumn<bool>(
    'remind_recaps',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("remind_recaps" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _remindBackupMeta = const VerificationMeta(
    'remindBackup',
  );
  @override
  late final GeneratedColumn<bool> remindBackup = GeneratedColumn<bool>(
    'remind_backup',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("remind_backup" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _quietFromMeta = const VerificationMeta(
    'quietFrom',
  );
  @override
  late final GeneratedColumn<int> quietFrom = GeneratedColumn<int>(
    'quiet_from',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1380),
  );
  static const VerificationMeta _biometricUnlockMeta = const VerificationMeta(
    'biometricUnlock',
  );
  @override
  late final GeneratedColumn<bool> biometricUnlock = GeneratedColumn<bool>(
    'biometric_unlock',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("biometric_unlock" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    currency,
    payFrequency,
    nextPayday,
    incomeType,
    displayName,
    hourlyRateCents,
    weekStartsOn,
    theme,
    appLockEnabled,
    overspendStrategy,
    onboarded,
    lastBackupOn,
    remindLogSpends,
    remindLogAt,
    remindBills,
    remindLatePause,
    remindRecaps,
    remindBackup,
    quietFrom,
    biometricUnlock,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    }
    if (data.containsKey('hourly_rate_cents')) {
      context.handle(
        _hourlyRateCentsMeta,
        hourlyRateCents.isAcceptableOrUnknown(
          data['hourly_rate_cents']!,
          _hourlyRateCentsMeta,
        ),
      );
    }
    if (data.containsKey('week_starts_on')) {
      context.handle(
        _weekStartsOnMeta,
        weekStartsOn.isAcceptableOrUnknown(
          data['week_starts_on']!,
          _weekStartsOnMeta,
        ),
      );
    }
    if (data.containsKey('app_lock_enabled')) {
      context.handle(
        _appLockEnabledMeta,
        appLockEnabled.isAcceptableOrUnknown(
          data['app_lock_enabled']!,
          _appLockEnabledMeta,
        ),
      );
    }
    if (data.containsKey('onboarded')) {
      context.handle(
        _onboardedMeta,
        onboarded.isAcceptableOrUnknown(data['onboarded']!, _onboardedMeta),
      );
    }
    if (data.containsKey('remind_log_spends')) {
      context.handle(
        _remindLogSpendsMeta,
        remindLogSpends.isAcceptableOrUnknown(
          data['remind_log_spends']!,
          _remindLogSpendsMeta,
        ),
      );
    }
    if (data.containsKey('remind_log_at')) {
      context.handle(
        _remindLogAtMeta,
        remindLogAt.isAcceptableOrUnknown(
          data['remind_log_at']!,
          _remindLogAtMeta,
        ),
      );
    }
    if (data.containsKey('remind_bills')) {
      context.handle(
        _remindBillsMeta,
        remindBills.isAcceptableOrUnknown(
          data['remind_bills']!,
          _remindBillsMeta,
        ),
      );
    }
    if (data.containsKey('remind_late_pause')) {
      context.handle(
        _remindLatePauseMeta,
        remindLatePause.isAcceptableOrUnknown(
          data['remind_late_pause']!,
          _remindLatePauseMeta,
        ),
      );
    }
    if (data.containsKey('remind_recaps')) {
      context.handle(
        _remindRecapsMeta,
        remindRecaps.isAcceptableOrUnknown(
          data['remind_recaps']!,
          _remindRecapsMeta,
        ),
      );
    }
    if (data.containsKey('remind_backup')) {
      context.handle(
        _remindBackupMeta,
        remindBackup.isAcceptableOrUnknown(
          data['remind_backup']!,
          _remindBackupMeta,
        ),
      );
    }
    if (data.containsKey('quiet_from')) {
      context.handle(
        _quietFromMeta,
        quietFrom.isAcceptableOrUnknown(data['quiet_from']!, _quietFromMeta),
      );
    }
    if (data.containsKey('biometric_unlock')) {
      context.handle(
        _biometricUnlockMeta,
        biometricUnlock.isAcceptableOrUnknown(
          data['biometric_unlock']!,
          _biometricUnlockMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SettingsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingsRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      currency: $SettingsRowsTable.$convertercurrency.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}currency'],
        )!,
      ),
      payFrequency: $SettingsRowsTable.$converterpayFrequency.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}pay_frequency'],
        )!,
      ),
      nextPayday: $SettingsRowsTable.$converternextPayday.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}next_payday'],
        )!,
      ),
      incomeType: $SettingsRowsTable.$converterincomeType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}income_type'],
        )!,
      ),
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      ),
      hourlyRateCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hourly_rate_cents'],
      ),
      weekStartsOn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}week_starts_on'],
      )!,
      theme: $SettingsRowsTable.$convertertheme.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}theme'],
        )!,
      ),
      appLockEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}app_lock_enabled'],
      )!,
      overspendStrategy: $SettingsRowsTable.$converteroverspendStrategy.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}overspend_strategy'],
        )!,
      ),
      onboarded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}onboarded'],
      )!,
      lastBackupOn: $SettingsRowsTable.$converterlastBackupOnn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}last_backup_on'],
        ),
      ),
      remindLogSpends: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}remind_log_spends'],
      )!,
      remindLogAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remind_log_at'],
      )!,
      remindBills: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}remind_bills'],
      )!,
      remindLatePause: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}remind_late_pause'],
      )!,
      remindRecaps: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}remind_recaps'],
      )!,
      remindBackup: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}remind_backup'],
      )!,
      quietFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quiet_from'],
      )!,
      biometricUnlock: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}biometric_unlock'],
      )!,
    );
  }

  @override
  $SettingsRowsTable createAlias(String alias) {
    return $SettingsRowsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Currency, String, String> $convertercurrency =
      const EnumNameConverter<Currency>(Currency.values);
  static JsonTypeConverter2<PayFrequency, String, String>
  $converterpayFrequency = const EnumNameConverter<PayFrequency>(
    PayFrequency.values,
  );
  static TypeConverter<LocalDate, String> $converternextPayday =
      const LocalDateConverter();
  static JsonTypeConverter2<IncomeType, String, String> $converterincomeType =
      const EnumNameConverter<IncomeType>(IncomeType.values);
  static JsonTypeConverter2<ThemePreference, String, String> $convertertheme =
      const EnumNameConverter<ThemePreference>(ThemePreference.values);
  static JsonTypeConverter2<OverspendStrategy, String, String>
  $converteroverspendStrategy = const EnumNameConverter<OverspendStrategy>(
    OverspendStrategy.values,
  );
  static TypeConverter<LocalDate, String> $converterlastBackupOn =
      const LocalDateConverter();
  static TypeConverter<LocalDate?, String?> $converterlastBackupOnn =
      NullAwareTypeConverter.wrap($converterlastBackupOn);
}

class SettingsRow extends DataClass implements Insertable<SettingsRow> {
  final int id;
  final Currency currency;
  final PayFrequency payFrequency;
  final LocalDate nextPayday;
  final IncomeType incomeType;
  final String? displayName;
  final int? hourlyRateCents;
  final int weekStartsOn;
  final ThemePreference theme;
  final bool appLockEnabled;
  final OverspendStrategy overspendStrategy;
  final bool onboarded;

  /// v3: when the user last created a .steady backup file.
  final LocalDate? lastBackupOn;

  /// v5: Reminders (see ReminderSettings for meanings and defaults).
  final bool remindLogSpends;
  final int remindLogAt;
  final bool remindBills;
  final bool remindLatePause;
  final bool remindRecaps;
  final bool remindBackup;
  final int quietFrom;

  /// v7: App lock also opens with Face ID / fingerprint.
  final bool biometricUnlock;
  const SettingsRow({
    required this.id,
    required this.currency,
    required this.payFrequency,
    required this.nextPayday,
    required this.incomeType,
    this.displayName,
    this.hourlyRateCents,
    required this.weekStartsOn,
    required this.theme,
    required this.appLockEnabled,
    required this.overspendStrategy,
    required this.onboarded,
    this.lastBackupOn,
    required this.remindLogSpends,
    required this.remindLogAt,
    required this.remindBills,
    required this.remindLatePause,
    required this.remindRecaps,
    required this.remindBackup,
    required this.quietFrom,
    required this.biometricUnlock,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['currency'] = Variable<String>(
        $SettingsRowsTable.$convertercurrency.toSql(currency),
      );
    }
    {
      map['pay_frequency'] = Variable<String>(
        $SettingsRowsTable.$converterpayFrequency.toSql(payFrequency),
      );
    }
    {
      map['next_payday'] = Variable<String>(
        $SettingsRowsTable.$converternextPayday.toSql(nextPayday),
      );
    }
    {
      map['income_type'] = Variable<String>(
        $SettingsRowsTable.$converterincomeType.toSql(incomeType),
      );
    }
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    if (!nullToAbsent || hourlyRateCents != null) {
      map['hourly_rate_cents'] = Variable<int>(hourlyRateCents);
    }
    map['week_starts_on'] = Variable<int>(weekStartsOn);
    {
      map['theme'] = Variable<String>(
        $SettingsRowsTable.$convertertheme.toSql(theme),
      );
    }
    map['app_lock_enabled'] = Variable<bool>(appLockEnabled);
    {
      map['overspend_strategy'] = Variable<String>(
        $SettingsRowsTable.$converteroverspendStrategy.toSql(overspendStrategy),
      );
    }
    map['onboarded'] = Variable<bool>(onboarded);
    if (!nullToAbsent || lastBackupOn != null) {
      map['last_backup_on'] = Variable<String>(
        $SettingsRowsTable.$converterlastBackupOnn.toSql(lastBackupOn),
      );
    }
    map['remind_log_spends'] = Variable<bool>(remindLogSpends);
    map['remind_log_at'] = Variable<int>(remindLogAt);
    map['remind_bills'] = Variable<bool>(remindBills);
    map['remind_late_pause'] = Variable<bool>(remindLatePause);
    map['remind_recaps'] = Variable<bool>(remindRecaps);
    map['remind_backup'] = Variable<bool>(remindBackup);
    map['quiet_from'] = Variable<int>(quietFrom);
    map['biometric_unlock'] = Variable<bool>(biometricUnlock);
    return map;
  }

  SettingsRowsCompanion toCompanion(bool nullToAbsent) {
    return SettingsRowsCompanion(
      id: Value(id),
      currency: Value(currency),
      payFrequency: Value(payFrequency),
      nextPayday: Value(nextPayday),
      incomeType: Value(incomeType),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      hourlyRateCents: hourlyRateCents == null && nullToAbsent
          ? const Value.absent()
          : Value(hourlyRateCents),
      weekStartsOn: Value(weekStartsOn),
      theme: Value(theme),
      appLockEnabled: Value(appLockEnabled),
      overspendStrategy: Value(overspendStrategy),
      onboarded: Value(onboarded),
      lastBackupOn: lastBackupOn == null && nullToAbsent
          ? const Value.absent()
          : Value(lastBackupOn),
      remindLogSpends: Value(remindLogSpends),
      remindLogAt: Value(remindLogAt),
      remindBills: Value(remindBills),
      remindLatePause: Value(remindLatePause),
      remindRecaps: Value(remindRecaps),
      remindBackup: Value(remindBackup),
      quietFrom: Value(quietFrom),
      biometricUnlock: Value(biometricUnlock),
    );
  }

  factory SettingsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingsRow(
      id: serializer.fromJson<int>(json['id']),
      currency: $SettingsRowsTable.$convertercurrency.fromJson(
        serializer.fromJson<String>(json['currency']),
      ),
      payFrequency: $SettingsRowsTable.$converterpayFrequency.fromJson(
        serializer.fromJson<String>(json['payFrequency']),
      ),
      nextPayday: serializer.fromJson<LocalDate>(json['nextPayday']),
      incomeType: $SettingsRowsTable.$converterincomeType.fromJson(
        serializer.fromJson<String>(json['incomeType']),
      ),
      displayName: serializer.fromJson<String?>(json['displayName']),
      hourlyRateCents: serializer.fromJson<int?>(json['hourlyRateCents']),
      weekStartsOn: serializer.fromJson<int>(json['weekStartsOn']),
      theme: $SettingsRowsTable.$convertertheme.fromJson(
        serializer.fromJson<String>(json['theme']),
      ),
      appLockEnabled: serializer.fromJson<bool>(json['appLockEnabled']),
      overspendStrategy: $SettingsRowsTable.$converteroverspendStrategy
          .fromJson(serializer.fromJson<String>(json['overspendStrategy'])),
      onboarded: serializer.fromJson<bool>(json['onboarded']),
      lastBackupOn: serializer.fromJson<LocalDate?>(json['lastBackupOn']),
      remindLogSpends: serializer.fromJson<bool>(json['remindLogSpends']),
      remindLogAt: serializer.fromJson<int>(json['remindLogAt']),
      remindBills: serializer.fromJson<bool>(json['remindBills']),
      remindLatePause: serializer.fromJson<bool>(json['remindLatePause']),
      remindRecaps: serializer.fromJson<bool>(json['remindRecaps']),
      remindBackup: serializer.fromJson<bool>(json['remindBackup']),
      quietFrom: serializer.fromJson<int>(json['quietFrom']),
      biometricUnlock: serializer.fromJson<bool>(json['biometricUnlock']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'currency': serializer.toJson<String>(
        $SettingsRowsTable.$convertercurrency.toJson(currency),
      ),
      'payFrequency': serializer.toJson<String>(
        $SettingsRowsTable.$converterpayFrequency.toJson(payFrequency),
      ),
      'nextPayday': serializer.toJson<LocalDate>(nextPayday),
      'incomeType': serializer.toJson<String>(
        $SettingsRowsTable.$converterincomeType.toJson(incomeType),
      ),
      'displayName': serializer.toJson<String?>(displayName),
      'hourlyRateCents': serializer.toJson<int?>(hourlyRateCents),
      'weekStartsOn': serializer.toJson<int>(weekStartsOn),
      'theme': serializer.toJson<String>(
        $SettingsRowsTable.$convertertheme.toJson(theme),
      ),
      'appLockEnabled': serializer.toJson<bool>(appLockEnabled),
      'overspendStrategy': serializer.toJson<String>(
        $SettingsRowsTable.$converteroverspendStrategy.toJson(
          overspendStrategy,
        ),
      ),
      'onboarded': serializer.toJson<bool>(onboarded),
      'lastBackupOn': serializer.toJson<LocalDate?>(lastBackupOn),
      'remindLogSpends': serializer.toJson<bool>(remindLogSpends),
      'remindLogAt': serializer.toJson<int>(remindLogAt),
      'remindBills': serializer.toJson<bool>(remindBills),
      'remindLatePause': serializer.toJson<bool>(remindLatePause),
      'remindRecaps': serializer.toJson<bool>(remindRecaps),
      'remindBackup': serializer.toJson<bool>(remindBackup),
      'quietFrom': serializer.toJson<int>(quietFrom),
      'biometricUnlock': serializer.toJson<bool>(biometricUnlock),
    };
  }

  SettingsRow copyWith({
    int? id,
    Currency? currency,
    PayFrequency? payFrequency,
    LocalDate? nextPayday,
    IncomeType? incomeType,
    Value<String?> displayName = const Value.absent(),
    Value<int?> hourlyRateCents = const Value.absent(),
    int? weekStartsOn,
    ThemePreference? theme,
    bool? appLockEnabled,
    OverspendStrategy? overspendStrategy,
    bool? onboarded,
    Value<LocalDate?> lastBackupOn = const Value.absent(),
    bool? remindLogSpends,
    int? remindLogAt,
    bool? remindBills,
    bool? remindLatePause,
    bool? remindRecaps,
    bool? remindBackup,
    int? quietFrom,
    bool? biometricUnlock,
  }) => SettingsRow(
    id: id ?? this.id,
    currency: currency ?? this.currency,
    payFrequency: payFrequency ?? this.payFrequency,
    nextPayday: nextPayday ?? this.nextPayday,
    incomeType: incomeType ?? this.incomeType,
    displayName: displayName.present ? displayName.value : this.displayName,
    hourlyRateCents: hourlyRateCents.present
        ? hourlyRateCents.value
        : this.hourlyRateCents,
    weekStartsOn: weekStartsOn ?? this.weekStartsOn,
    theme: theme ?? this.theme,
    appLockEnabled: appLockEnabled ?? this.appLockEnabled,
    overspendStrategy: overspendStrategy ?? this.overspendStrategy,
    onboarded: onboarded ?? this.onboarded,
    lastBackupOn: lastBackupOn.present ? lastBackupOn.value : this.lastBackupOn,
    remindLogSpends: remindLogSpends ?? this.remindLogSpends,
    remindLogAt: remindLogAt ?? this.remindLogAt,
    remindBills: remindBills ?? this.remindBills,
    remindLatePause: remindLatePause ?? this.remindLatePause,
    remindRecaps: remindRecaps ?? this.remindRecaps,
    remindBackup: remindBackup ?? this.remindBackup,
    quietFrom: quietFrom ?? this.quietFrom,
    biometricUnlock: biometricUnlock ?? this.biometricUnlock,
  );
  SettingsRow copyWithCompanion(SettingsRowsCompanion data) {
    return SettingsRow(
      id: data.id.present ? data.id.value : this.id,
      currency: data.currency.present ? data.currency.value : this.currency,
      payFrequency: data.payFrequency.present
          ? data.payFrequency.value
          : this.payFrequency,
      nextPayday: data.nextPayday.present
          ? data.nextPayday.value
          : this.nextPayday,
      incomeType: data.incomeType.present
          ? data.incomeType.value
          : this.incomeType,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      hourlyRateCents: data.hourlyRateCents.present
          ? data.hourlyRateCents.value
          : this.hourlyRateCents,
      weekStartsOn: data.weekStartsOn.present
          ? data.weekStartsOn.value
          : this.weekStartsOn,
      theme: data.theme.present ? data.theme.value : this.theme,
      appLockEnabled: data.appLockEnabled.present
          ? data.appLockEnabled.value
          : this.appLockEnabled,
      overspendStrategy: data.overspendStrategy.present
          ? data.overspendStrategy.value
          : this.overspendStrategy,
      onboarded: data.onboarded.present ? data.onboarded.value : this.onboarded,
      lastBackupOn: data.lastBackupOn.present
          ? data.lastBackupOn.value
          : this.lastBackupOn,
      remindLogSpends: data.remindLogSpends.present
          ? data.remindLogSpends.value
          : this.remindLogSpends,
      remindLogAt: data.remindLogAt.present
          ? data.remindLogAt.value
          : this.remindLogAt,
      remindBills: data.remindBills.present
          ? data.remindBills.value
          : this.remindBills,
      remindLatePause: data.remindLatePause.present
          ? data.remindLatePause.value
          : this.remindLatePause,
      remindRecaps: data.remindRecaps.present
          ? data.remindRecaps.value
          : this.remindRecaps,
      remindBackup: data.remindBackup.present
          ? data.remindBackup.value
          : this.remindBackup,
      quietFrom: data.quietFrom.present ? data.quietFrom.value : this.quietFrom,
      biometricUnlock: data.biometricUnlock.present
          ? data.biometricUnlock.value
          : this.biometricUnlock,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingsRow(')
          ..write('id: $id, ')
          ..write('currency: $currency, ')
          ..write('payFrequency: $payFrequency, ')
          ..write('nextPayday: $nextPayday, ')
          ..write('incomeType: $incomeType, ')
          ..write('displayName: $displayName, ')
          ..write('hourlyRateCents: $hourlyRateCents, ')
          ..write('weekStartsOn: $weekStartsOn, ')
          ..write('theme: $theme, ')
          ..write('appLockEnabled: $appLockEnabled, ')
          ..write('overspendStrategy: $overspendStrategy, ')
          ..write('onboarded: $onboarded, ')
          ..write('lastBackupOn: $lastBackupOn, ')
          ..write('remindLogSpends: $remindLogSpends, ')
          ..write('remindLogAt: $remindLogAt, ')
          ..write('remindBills: $remindBills, ')
          ..write('remindLatePause: $remindLatePause, ')
          ..write('remindRecaps: $remindRecaps, ')
          ..write('remindBackup: $remindBackup, ')
          ..write('quietFrom: $quietFrom, ')
          ..write('biometricUnlock: $biometricUnlock')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    currency,
    payFrequency,
    nextPayday,
    incomeType,
    displayName,
    hourlyRateCents,
    weekStartsOn,
    theme,
    appLockEnabled,
    overspendStrategy,
    onboarded,
    lastBackupOn,
    remindLogSpends,
    remindLogAt,
    remindBills,
    remindLatePause,
    remindRecaps,
    remindBackup,
    quietFrom,
    biometricUnlock,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingsRow &&
          other.id == this.id &&
          other.currency == this.currency &&
          other.payFrequency == this.payFrequency &&
          other.nextPayday == this.nextPayday &&
          other.incomeType == this.incomeType &&
          other.displayName == this.displayName &&
          other.hourlyRateCents == this.hourlyRateCents &&
          other.weekStartsOn == this.weekStartsOn &&
          other.theme == this.theme &&
          other.appLockEnabled == this.appLockEnabled &&
          other.overspendStrategy == this.overspendStrategy &&
          other.onboarded == this.onboarded &&
          other.lastBackupOn == this.lastBackupOn &&
          other.remindLogSpends == this.remindLogSpends &&
          other.remindLogAt == this.remindLogAt &&
          other.remindBills == this.remindBills &&
          other.remindLatePause == this.remindLatePause &&
          other.remindRecaps == this.remindRecaps &&
          other.remindBackup == this.remindBackup &&
          other.quietFrom == this.quietFrom &&
          other.biometricUnlock == this.biometricUnlock);
}

class SettingsRowsCompanion extends UpdateCompanion<SettingsRow> {
  final Value<int> id;
  final Value<Currency> currency;
  final Value<PayFrequency> payFrequency;
  final Value<LocalDate> nextPayday;
  final Value<IncomeType> incomeType;
  final Value<String?> displayName;
  final Value<int?> hourlyRateCents;
  final Value<int> weekStartsOn;
  final Value<ThemePreference> theme;
  final Value<bool> appLockEnabled;
  final Value<OverspendStrategy> overspendStrategy;
  final Value<bool> onboarded;
  final Value<LocalDate?> lastBackupOn;
  final Value<bool> remindLogSpends;
  final Value<int> remindLogAt;
  final Value<bool> remindBills;
  final Value<bool> remindLatePause;
  final Value<bool> remindRecaps;
  final Value<bool> remindBackup;
  final Value<int> quietFrom;
  final Value<bool> biometricUnlock;
  const SettingsRowsCompanion({
    this.id = const Value.absent(),
    this.currency = const Value.absent(),
    this.payFrequency = const Value.absent(),
    this.nextPayday = const Value.absent(),
    this.incomeType = const Value.absent(),
    this.displayName = const Value.absent(),
    this.hourlyRateCents = const Value.absent(),
    this.weekStartsOn = const Value.absent(),
    this.theme = const Value.absent(),
    this.appLockEnabled = const Value.absent(),
    this.overspendStrategy = const Value.absent(),
    this.onboarded = const Value.absent(),
    this.lastBackupOn = const Value.absent(),
    this.remindLogSpends = const Value.absent(),
    this.remindLogAt = const Value.absent(),
    this.remindBills = const Value.absent(),
    this.remindLatePause = const Value.absent(),
    this.remindRecaps = const Value.absent(),
    this.remindBackup = const Value.absent(),
    this.quietFrom = const Value.absent(),
    this.biometricUnlock = const Value.absent(),
  });
  SettingsRowsCompanion.insert({
    this.id = const Value.absent(),
    required Currency currency,
    required PayFrequency payFrequency,
    required LocalDate nextPayday,
    required IncomeType incomeType,
    this.displayName = const Value.absent(),
    this.hourlyRateCents = const Value.absent(),
    this.weekStartsOn = const Value.absent(),
    required ThemePreference theme,
    this.appLockEnabled = const Value.absent(),
    required OverspendStrategy overspendStrategy,
    this.onboarded = const Value.absent(),
    this.lastBackupOn = const Value.absent(),
    this.remindLogSpends = const Value.absent(),
    this.remindLogAt = const Value.absent(),
    this.remindBills = const Value.absent(),
    this.remindLatePause = const Value.absent(),
    this.remindRecaps = const Value.absent(),
    this.remindBackup = const Value.absent(),
    this.quietFrom = const Value.absent(),
    this.biometricUnlock = const Value.absent(),
  }) : currency = Value(currency),
       payFrequency = Value(payFrequency),
       nextPayday = Value(nextPayday),
       incomeType = Value(incomeType),
       theme = Value(theme),
       overspendStrategy = Value(overspendStrategy);
  static Insertable<SettingsRow> custom({
    Expression<int>? id,
    Expression<String>? currency,
    Expression<String>? payFrequency,
    Expression<String>? nextPayday,
    Expression<String>? incomeType,
    Expression<String>? displayName,
    Expression<int>? hourlyRateCents,
    Expression<int>? weekStartsOn,
    Expression<String>? theme,
    Expression<bool>? appLockEnabled,
    Expression<String>? overspendStrategy,
    Expression<bool>? onboarded,
    Expression<String>? lastBackupOn,
    Expression<bool>? remindLogSpends,
    Expression<int>? remindLogAt,
    Expression<bool>? remindBills,
    Expression<bool>? remindLatePause,
    Expression<bool>? remindRecaps,
    Expression<bool>? remindBackup,
    Expression<int>? quietFrom,
    Expression<bool>? biometricUnlock,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (currency != null) 'currency': currency,
      if (payFrequency != null) 'pay_frequency': payFrequency,
      if (nextPayday != null) 'next_payday': nextPayday,
      if (incomeType != null) 'income_type': incomeType,
      if (displayName != null) 'display_name': displayName,
      if (hourlyRateCents != null) 'hourly_rate_cents': hourlyRateCents,
      if (weekStartsOn != null) 'week_starts_on': weekStartsOn,
      if (theme != null) 'theme': theme,
      if (appLockEnabled != null) 'app_lock_enabled': appLockEnabled,
      if (overspendStrategy != null) 'overspend_strategy': overspendStrategy,
      if (onboarded != null) 'onboarded': onboarded,
      if (lastBackupOn != null) 'last_backup_on': lastBackupOn,
      if (remindLogSpends != null) 'remind_log_spends': remindLogSpends,
      if (remindLogAt != null) 'remind_log_at': remindLogAt,
      if (remindBills != null) 'remind_bills': remindBills,
      if (remindLatePause != null) 'remind_late_pause': remindLatePause,
      if (remindRecaps != null) 'remind_recaps': remindRecaps,
      if (remindBackup != null) 'remind_backup': remindBackup,
      if (quietFrom != null) 'quiet_from': quietFrom,
      if (biometricUnlock != null) 'biometric_unlock': biometricUnlock,
    });
  }

  SettingsRowsCompanion copyWith({
    Value<int>? id,
    Value<Currency>? currency,
    Value<PayFrequency>? payFrequency,
    Value<LocalDate>? nextPayday,
    Value<IncomeType>? incomeType,
    Value<String?>? displayName,
    Value<int?>? hourlyRateCents,
    Value<int>? weekStartsOn,
    Value<ThemePreference>? theme,
    Value<bool>? appLockEnabled,
    Value<OverspendStrategy>? overspendStrategy,
    Value<bool>? onboarded,
    Value<LocalDate?>? lastBackupOn,
    Value<bool>? remindLogSpends,
    Value<int>? remindLogAt,
    Value<bool>? remindBills,
    Value<bool>? remindLatePause,
    Value<bool>? remindRecaps,
    Value<bool>? remindBackup,
    Value<int>? quietFrom,
    Value<bool>? biometricUnlock,
  }) {
    return SettingsRowsCompanion(
      id: id ?? this.id,
      currency: currency ?? this.currency,
      payFrequency: payFrequency ?? this.payFrequency,
      nextPayday: nextPayday ?? this.nextPayday,
      incomeType: incomeType ?? this.incomeType,
      displayName: displayName ?? this.displayName,
      hourlyRateCents: hourlyRateCents ?? this.hourlyRateCents,
      weekStartsOn: weekStartsOn ?? this.weekStartsOn,
      theme: theme ?? this.theme,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      overspendStrategy: overspendStrategy ?? this.overspendStrategy,
      onboarded: onboarded ?? this.onboarded,
      lastBackupOn: lastBackupOn ?? this.lastBackupOn,
      remindLogSpends: remindLogSpends ?? this.remindLogSpends,
      remindLogAt: remindLogAt ?? this.remindLogAt,
      remindBills: remindBills ?? this.remindBills,
      remindLatePause: remindLatePause ?? this.remindLatePause,
      remindRecaps: remindRecaps ?? this.remindRecaps,
      remindBackup: remindBackup ?? this.remindBackup,
      quietFrom: quietFrom ?? this.quietFrom,
      biometricUnlock: biometricUnlock ?? this.biometricUnlock,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(
        $SettingsRowsTable.$convertercurrency.toSql(currency.value),
      );
    }
    if (payFrequency.present) {
      map['pay_frequency'] = Variable<String>(
        $SettingsRowsTable.$converterpayFrequency.toSql(payFrequency.value),
      );
    }
    if (nextPayday.present) {
      map['next_payday'] = Variable<String>(
        $SettingsRowsTable.$converternextPayday.toSql(nextPayday.value),
      );
    }
    if (incomeType.present) {
      map['income_type'] = Variable<String>(
        $SettingsRowsTable.$converterincomeType.toSql(incomeType.value),
      );
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (hourlyRateCents.present) {
      map['hourly_rate_cents'] = Variable<int>(hourlyRateCents.value);
    }
    if (weekStartsOn.present) {
      map['week_starts_on'] = Variable<int>(weekStartsOn.value);
    }
    if (theme.present) {
      map['theme'] = Variable<String>(
        $SettingsRowsTable.$convertertheme.toSql(theme.value),
      );
    }
    if (appLockEnabled.present) {
      map['app_lock_enabled'] = Variable<bool>(appLockEnabled.value);
    }
    if (overspendStrategy.present) {
      map['overspend_strategy'] = Variable<String>(
        $SettingsRowsTable.$converteroverspendStrategy.toSql(
          overspendStrategy.value,
        ),
      );
    }
    if (onboarded.present) {
      map['onboarded'] = Variable<bool>(onboarded.value);
    }
    if (lastBackupOn.present) {
      map['last_backup_on'] = Variable<String>(
        $SettingsRowsTable.$converterlastBackupOnn.toSql(lastBackupOn.value),
      );
    }
    if (remindLogSpends.present) {
      map['remind_log_spends'] = Variable<bool>(remindLogSpends.value);
    }
    if (remindLogAt.present) {
      map['remind_log_at'] = Variable<int>(remindLogAt.value);
    }
    if (remindBills.present) {
      map['remind_bills'] = Variable<bool>(remindBills.value);
    }
    if (remindLatePause.present) {
      map['remind_late_pause'] = Variable<bool>(remindLatePause.value);
    }
    if (remindRecaps.present) {
      map['remind_recaps'] = Variable<bool>(remindRecaps.value);
    }
    if (remindBackup.present) {
      map['remind_backup'] = Variable<bool>(remindBackup.value);
    }
    if (quietFrom.present) {
      map['quiet_from'] = Variable<int>(quietFrom.value);
    }
    if (biometricUnlock.present) {
      map['biometric_unlock'] = Variable<bool>(biometricUnlock.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsRowsCompanion(')
          ..write('id: $id, ')
          ..write('currency: $currency, ')
          ..write('payFrequency: $payFrequency, ')
          ..write('nextPayday: $nextPayday, ')
          ..write('incomeType: $incomeType, ')
          ..write('displayName: $displayName, ')
          ..write('hourlyRateCents: $hourlyRateCents, ')
          ..write('weekStartsOn: $weekStartsOn, ')
          ..write('theme: $theme, ')
          ..write('appLockEnabled: $appLockEnabled, ')
          ..write('overspendStrategy: $overspendStrategy, ')
          ..write('onboarded: $onboarded, ')
          ..write('lastBackupOn: $lastBackupOn, ')
          ..write('remindLogSpends: $remindLogSpends, ')
          ..write('remindLogAt: $remindLogAt, ')
          ..write('remindBills: $remindBills, ')
          ..write('remindLatePause: $remindLatePause, ')
          ..write('remindRecaps: $remindRecaps, ')
          ..write('remindBackup: $remindBackup, ')
          ..write('quietFrom: $quietFrom, ')
          ..write('biometricUnlock: $biometricUnlock')
          ..write(')'))
        .toString();
  }
}

class $CyclePlansTable extends CyclePlans
    with TableInfo<$CyclePlansTable, CyclePlanRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CyclePlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  late final GeneratedColumnWithTypeConverter<LocalDate, String> startDate =
      GeneratedColumn<String>(
        'start_date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LocalDate>($CyclePlansTable.$converterstartDate);
  static const VerificationMeta _openingBalanceCentsMeta =
      const VerificationMeta('openingBalanceCents');
  @override
  late final GeneratedColumn<int> openingBalanceCents = GeneratedColumn<int>(
    'opening_balance_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _goalSetAsideCentsMeta = const VerificationMeta(
    'goalSetAsideCents',
  );
  @override
  late final GeneratedColumn<int> goalSetAsideCents = GeneratedColumn<int>(
    'goal_set_aside_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startDate,
    openingBalanceCents,
    goalSetAsideCents,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cycle_plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<CyclePlanRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('opening_balance_cents')) {
      context.handle(
        _openingBalanceCentsMeta,
        openingBalanceCents.isAcceptableOrUnknown(
          data['opening_balance_cents']!,
          _openingBalanceCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_openingBalanceCentsMeta);
    }
    if (data.containsKey('goal_set_aside_cents')) {
      context.handle(
        _goalSetAsideCentsMeta,
        goalSetAsideCents.isAcceptableOrUnknown(
          data['goal_set_aside_cents']!,
          _goalSetAsideCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_goalSetAsideCentsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CyclePlanRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CyclePlanRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      startDate: $CyclePlansTable.$converterstartDate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}start_date'],
        )!,
      ),
      openingBalanceCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}opening_balance_cents'],
      )!,
      goalSetAsideCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}goal_set_aside_cents'],
      )!,
    );
  }

  @override
  $CyclePlansTable createAlias(String alias) {
    return $CyclePlansTable(attachedDatabase, alias);
  }

  static TypeConverter<LocalDate, String> $converterstartDate =
      const LocalDateConverter();
}

class CyclePlanRow extends DataClass implements Insertable<CyclePlanRow> {
  final int id;
  final LocalDate startDate;
  final int openingBalanceCents;
  final int goalSetAsideCents;
  const CyclePlanRow({
    required this.id,
    required this.startDate,
    required this.openingBalanceCents,
    required this.goalSetAsideCents,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['start_date'] = Variable<String>(
        $CyclePlansTable.$converterstartDate.toSql(startDate),
      );
    }
    map['opening_balance_cents'] = Variable<int>(openingBalanceCents);
    map['goal_set_aside_cents'] = Variable<int>(goalSetAsideCents);
    return map;
  }

  CyclePlansCompanion toCompanion(bool nullToAbsent) {
    return CyclePlansCompanion(
      id: Value(id),
      startDate: Value(startDate),
      openingBalanceCents: Value(openingBalanceCents),
      goalSetAsideCents: Value(goalSetAsideCents),
    );
  }

  factory CyclePlanRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CyclePlanRow(
      id: serializer.fromJson<int>(json['id']),
      startDate: serializer.fromJson<LocalDate>(json['startDate']),
      openingBalanceCents: serializer.fromJson<int>(
        json['openingBalanceCents'],
      ),
      goalSetAsideCents: serializer.fromJson<int>(json['goalSetAsideCents']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startDate': serializer.toJson<LocalDate>(startDate),
      'openingBalanceCents': serializer.toJson<int>(openingBalanceCents),
      'goalSetAsideCents': serializer.toJson<int>(goalSetAsideCents),
    };
  }

  CyclePlanRow copyWith({
    int? id,
    LocalDate? startDate,
    int? openingBalanceCents,
    int? goalSetAsideCents,
  }) => CyclePlanRow(
    id: id ?? this.id,
    startDate: startDate ?? this.startDate,
    openingBalanceCents: openingBalanceCents ?? this.openingBalanceCents,
    goalSetAsideCents: goalSetAsideCents ?? this.goalSetAsideCents,
  );
  CyclePlanRow copyWithCompanion(CyclePlansCompanion data) {
    return CyclePlanRow(
      id: data.id.present ? data.id.value : this.id,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      openingBalanceCents: data.openingBalanceCents.present
          ? data.openingBalanceCents.value
          : this.openingBalanceCents,
      goalSetAsideCents: data.goalSetAsideCents.present
          ? data.goalSetAsideCents.value
          : this.goalSetAsideCents,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CyclePlanRow(')
          ..write('id: $id, ')
          ..write('startDate: $startDate, ')
          ..write('openingBalanceCents: $openingBalanceCents, ')
          ..write('goalSetAsideCents: $goalSetAsideCents')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, startDate, openingBalanceCents, goalSetAsideCents);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CyclePlanRow &&
          other.id == this.id &&
          other.startDate == this.startDate &&
          other.openingBalanceCents == this.openingBalanceCents &&
          other.goalSetAsideCents == this.goalSetAsideCents);
}

class CyclePlansCompanion extends UpdateCompanion<CyclePlanRow> {
  final Value<int> id;
  final Value<LocalDate> startDate;
  final Value<int> openingBalanceCents;
  final Value<int> goalSetAsideCents;
  const CyclePlansCompanion({
    this.id = const Value.absent(),
    this.startDate = const Value.absent(),
    this.openingBalanceCents = const Value.absent(),
    this.goalSetAsideCents = const Value.absent(),
  });
  CyclePlansCompanion.insert({
    this.id = const Value.absent(),
    required LocalDate startDate,
    required int openingBalanceCents,
    required int goalSetAsideCents,
  }) : startDate = Value(startDate),
       openingBalanceCents = Value(openingBalanceCents),
       goalSetAsideCents = Value(goalSetAsideCents);
  static Insertable<CyclePlanRow> custom({
    Expression<int>? id,
    Expression<String>? startDate,
    Expression<int>? openingBalanceCents,
    Expression<int>? goalSetAsideCents,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startDate != null) 'start_date': startDate,
      if (openingBalanceCents != null)
        'opening_balance_cents': openingBalanceCents,
      if (goalSetAsideCents != null) 'goal_set_aside_cents': goalSetAsideCents,
    });
  }

  CyclePlansCompanion copyWith({
    Value<int>? id,
    Value<LocalDate>? startDate,
    Value<int>? openingBalanceCents,
    Value<int>? goalSetAsideCents,
  }) {
    return CyclePlansCompanion(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      openingBalanceCents: openingBalanceCents ?? this.openingBalanceCents,
      goalSetAsideCents: goalSetAsideCents ?? this.goalSetAsideCents,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(
        $CyclePlansTable.$converterstartDate.toSql(startDate.value),
      );
    }
    if (openingBalanceCents.present) {
      map['opening_balance_cents'] = Variable<int>(openingBalanceCents.value);
    }
    if (goalSetAsideCents.present) {
      map['goal_set_aside_cents'] = Variable<int>(goalSetAsideCents.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CyclePlansCompanion(')
          ..write('id: $id, ')
          ..write('startDate: $startDate, ')
          ..write('openingBalanceCents: $openingBalanceCents, ')
          ..write('goalSetAsideCents: $goalSetAsideCents')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<CategoryTone, String> tone =
      GeneratedColumn<String>(
        'tone',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<CategoryTone>($CategoriesTable.$convertertone);
  static const VerificationMeta _monthlyLimitCentsMeta = const VerificationMeta(
    'monthlyLimitCents',
  );
  @override
  late final GeneratedColumn<int> monthlyLimitCents = GeneratedColumn<int>(
    'monthly_limit_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    tone,
    monthlyLimitCents,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('monthly_limit_cents')) {
      context.handle(
        _monthlyLimitCentsMeta,
        monthlyLimitCents.isAcceptableOrUnknown(
          data['monthly_limit_cents']!,
          _monthlyLimitCentsMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      tone: $CategoriesTable.$convertertone.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tone'],
        )!,
      ),
      monthlyLimitCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monthly_limit_cents'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CategoryTone, String, String> $convertertone =
      const EnumNameConverter<CategoryTone>(CategoryTone.values);
}

class CategoryRow extends DataClass implements Insertable<CategoryRow> {
  final String id;
  final String name;
  final CategoryTone tone;
  final int? monthlyLimitCents;
  final int sortOrder;
  const CategoryRow({
    required this.id,
    required this.name,
    required this.tone,
    this.monthlyLimitCents,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    {
      map['tone'] = Variable<String>(
        $CategoriesTable.$convertertone.toSql(tone),
      );
    }
    if (!nullToAbsent || monthlyLimitCents != null) {
      map['monthly_limit_cents'] = Variable<int>(monthlyLimitCents);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      tone: Value(tone),
      monthlyLimitCents: monthlyLimitCents == null && nullToAbsent
          ? const Value.absent()
          : Value(monthlyLimitCents),
      sortOrder: Value(sortOrder),
    );
  }

  factory CategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      tone: $CategoriesTable.$convertertone.fromJson(
        serializer.fromJson<String>(json['tone']),
      ),
      monthlyLimitCents: serializer.fromJson<int?>(json['monthlyLimitCents']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'tone': serializer.toJson<String>(
        $CategoriesTable.$convertertone.toJson(tone),
      ),
      'monthlyLimitCents': serializer.toJson<int?>(monthlyLimitCents),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  CategoryRow copyWith({
    String? id,
    String? name,
    CategoryTone? tone,
    Value<int?> monthlyLimitCents = const Value.absent(),
    int? sortOrder,
  }) => CategoryRow(
    id: id ?? this.id,
    name: name ?? this.name,
    tone: tone ?? this.tone,
    monthlyLimitCents: monthlyLimitCents.present
        ? monthlyLimitCents.value
        : this.monthlyLimitCents,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  CategoryRow copyWithCompanion(CategoriesCompanion data) {
    return CategoryRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      tone: data.tone.present ? data.tone.value : this.tone,
      monthlyLimitCents: data.monthlyLimitCents.present
          ? data.monthlyLimitCents.value
          : this.monthlyLimitCents,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('tone: $tone, ')
          ..write('monthlyLimitCents: $monthlyLimitCents, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, tone, monthlyLimitCents, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.tone == this.tone &&
          other.monthlyLimitCents == this.monthlyLimitCents &&
          other.sortOrder == this.sortOrder);
}

class CategoriesCompanion extends UpdateCompanion<CategoryRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<CategoryTone> tone;
  final Value<int?> monthlyLimitCents;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.tone = const Value.absent(),
    this.monthlyLimitCents = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String name,
    required CategoryTone tone,
    this.monthlyLimitCents = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       tone = Value(tone);
  static Insertable<CategoryRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? tone,
    Expression<int>? monthlyLimitCents,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (tone != null) 'tone': tone,
      if (monthlyLimitCents != null) 'monthly_limit_cents': monthlyLimitCents,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<CategoryTone>? tone,
    Value<int?>? monthlyLimitCents,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      tone: tone ?? this.tone,
      monthlyLimitCents: monthlyLimitCents ?? this.monthlyLimitCents,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (tone.present) {
      map['tone'] = Variable<String>(
        $CategoriesTable.$convertertone.toSql(tone.value),
      );
    }
    if (monthlyLimitCents.present) {
      map['monthly_limit_cents'] = Variable<int>(monthlyLimitCents.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('tone: $tone, ')
          ..write('monthlyLimitCents: $monthlyLimitCents, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EntriesTable extends Entries with TableInfo<$EntriesTable, EntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<EntryType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<EntryType>($EntriesTable.$convertertype);
  static const VerificationMeta _amountCentsMeta = const VerificationMeta(
    'amountCents',
  );
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
    'amount_cents',
    aliasedName,
    false,
    check: () => ComparableExpr(amountCents).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<LocalDate, String> localDate =
      GeneratedColumn<String>(
        'local_date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LocalDate>($EntriesTable.$converterlocalDate);
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> createdAtUtc = GeneratedColumn<DateTime>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeZoneIdMeta = const VerificationMeta(
    'timeZoneId',
  );
  @override
  late final GeneratedColumn<String> timeZoneId = GeneratedColumn<String>(
    'time_zone_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _merchantMeta = const VerificationMeta(
    'merchant',
  );
  @override
  late final GeneratedColumn<String> merchant = GeneratedColumn<String>(
    'merchant',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Mood?, String> mood =
      GeneratedColumn<String>(
        'mood',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Mood?>($EntriesTable.$convertermoodn);
  static const VerificationMeta _plannedMeta = const VerificationMeta(
    'planned',
  );
  @override
  late final GeneratedColumn<bool> planned = GeneratedColumn<bool>(
    'planned',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("planned" IN (0, 1))',
    ),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _splitIdMeta = const VerificationMeta(
    'splitId',
  );
  @override
  late final GeneratedColumn<String> splitId = GeneratedColumn<String>(
    'split_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _toVaultMeta = const VerificationMeta(
    'toVault',
  );
  @override
  late final GeneratedColumn<bool> toVault = GeneratedColumn<bool>(
    'to_vault',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("to_vault" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _fromVaultMeta = const VerificationMeta(
    'fromVault',
  );
  @override
  late final GeneratedColumn<bool> fromVault = GeneratedColumn<bool>(
    'from_vault',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("from_vault" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _billIdMeta = const VerificationMeta('billId');
  @override
  late final GeneratedColumn<String> billId = GeneratedColumn<String>(
    'bill_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    amountCents,
    localDate,
    createdAtUtc,
    timeZoneId,
    merchant,
    categoryId,
    mood,
    planned,
    note,
    splitId,
    toVault,
    fromVault,
    billId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
        _amountCentsMeta,
        amountCents.isAcceptableOrUnknown(
          data['amount_cents']!,
          _amountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountCentsMeta);
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('time_zone_id')) {
      context.handle(
        _timeZoneIdMeta,
        timeZoneId.isAcceptableOrUnknown(
          data['time_zone_id']!,
          _timeZoneIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timeZoneIdMeta);
    }
    if (data.containsKey('merchant')) {
      context.handle(
        _merchantMeta,
        merchant.isAcceptableOrUnknown(data['merchant']!, _merchantMeta),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('planned')) {
      context.handle(
        _plannedMeta,
        planned.isAcceptableOrUnknown(data['planned']!, _plannedMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('split_id')) {
      context.handle(
        _splitIdMeta,
        splitId.isAcceptableOrUnknown(data['split_id']!, _splitIdMeta),
      );
    }
    if (data.containsKey('to_vault')) {
      context.handle(
        _toVaultMeta,
        toVault.isAcceptableOrUnknown(data['to_vault']!, _toVaultMeta),
      );
    }
    if (data.containsKey('from_vault')) {
      context.handle(
        _fromVaultMeta,
        fromVault.isAcceptableOrUnknown(data['from_vault']!, _fromVaultMeta),
      );
    }
    if (data.containsKey('bill_id')) {
      context.handle(
        _billIdMeta,
        billId.isAcceptableOrUnknown(data['bill_id']!, _billIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: $EntriesTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      amountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_cents'],
      )!,
      localDate: $EntriesTable.$converterlocalDate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}local_date'],
        )!,
      ),
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at_utc'],
      )!,
      timeZoneId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_zone_id'],
      )!,
      merchant: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}merchant'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      mood: $EntriesTable.$convertermoodn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}mood'],
        ),
      ),
      planned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}planned'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      splitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}split_id'],
      ),
      toVault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}to_vault'],
      )!,
      fromVault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}from_vault'],
      )!,
      billId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bill_id'],
      ),
    );
  }

  @override
  $EntriesTable createAlias(String alias) {
    return $EntriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<EntryType, String, String> $convertertype =
      const EnumNameConverter<EntryType>(EntryType.values);
  static TypeConverter<LocalDate, String> $converterlocalDate =
      const LocalDateConverter();
  static JsonTypeConverter2<Mood, String, String> $convertermood =
      const EnumNameConverter<Mood>(Mood.values);
  static JsonTypeConverter2<Mood?, String?, String?> $convertermoodn =
      JsonTypeConverter2.asNullable($convertermood);
}

class EntryRow extends DataClass implements Insertable<EntryRow> {
  final String id;
  final EntryType type;
  final int amountCents;

  /// The local calendar day the entry belongs to; never re-derived from the
  /// timestamp, so travel and clock changes don't move it (Handoff 4).
  final LocalDate localDate;
  final DateTime createdAtUtc;
  final String timeZoneId;
  final String? merchant;

  /// No foreign key: deleting a category keeps its entries (they just lose
  /// the category), as the Edit category screen promises.
  final String? categoryId;
  final Mood? mood;
  final bool? planned;
  final String? note;
  final String? splitId;
  final bool toVault;

  /// v2: a weekly Paycheck Vault release into the daily number.
  final bool fromVault;

  /// v2: the bill this spend paid (bill payments don't count against
  /// today's allowance).
  final String? billId;
  const EntryRow({
    required this.id,
    required this.type,
    required this.amountCents,
    required this.localDate,
    required this.createdAtUtc,
    required this.timeZoneId,
    this.merchant,
    this.categoryId,
    this.mood,
    this.planned,
    this.note,
    this.splitId,
    required this.toVault,
    required this.fromVault,
    this.billId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['type'] = Variable<String>($EntriesTable.$convertertype.toSql(type));
    }
    map['amount_cents'] = Variable<int>(amountCents);
    {
      map['local_date'] = Variable<String>(
        $EntriesTable.$converterlocalDate.toSql(localDate),
      );
    }
    map['created_at_utc'] = Variable<DateTime>(createdAtUtc);
    map['time_zone_id'] = Variable<String>(timeZoneId);
    if (!nullToAbsent || merchant != null) {
      map['merchant'] = Variable<String>(merchant);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    if (!nullToAbsent || mood != null) {
      map['mood'] = Variable<String>($EntriesTable.$convertermoodn.toSql(mood));
    }
    if (!nullToAbsent || planned != null) {
      map['planned'] = Variable<bool>(planned);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || splitId != null) {
      map['split_id'] = Variable<String>(splitId);
    }
    map['to_vault'] = Variable<bool>(toVault);
    map['from_vault'] = Variable<bool>(fromVault);
    if (!nullToAbsent || billId != null) {
      map['bill_id'] = Variable<String>(billId);
    }
    return map;
  }

  EntriesCompanion toCompanion(bool nullToAbsent) {
    return EntriesCompanion(
      id: Value(id),
      type: Value(type),
      amountCents: Value(amountCents),
      localDate: Value(localDate),
      createdAtUtc: Value(createdAtUtc),
      timeZoneId: Value(timeZoneId),
      merchant: merchant == null && nullToAbsent
          ? const Value.absent()
          : Value(merchant),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      mood: mood == null && nullToAbsent ? const Value.absent() : Value(mood),
      planned: planned == null && nullToAbsent
          ? const Value.absent()
          : Value(planned),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      splitId: splitId == null && nullToAbsent
          ? const Value.absent()
          : Value(splitId),
      toVault: Value(toVault),
      fromVault: Value(fromVault),
      billId: billId == null && nullToAbsent
          ? const Value.absent()
          : Value(billId),
    );
  }

  factory EntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntryRow(
      id: serializer.fromJson<String>(json['id']),
      type: $EntriesTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      amountCents: serializer.fromJson<int>(json['amountCents']),
      localDate: serializer.fromJson<LocalDate>(json['localDate']),
      createdAtUtc: serializer.fromJson<DateTime>(json['createdAtUtc']),
      timeZoneId: serializer.fromJson<String>(json['timeZoneId']),
      merchant: serializer.fromJson<String?>(json['merchant']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      mood: $EntriesTable.$convertermoodn.fromJson(
        serializer.fromJson<String?>(json['mood']),
      ),
      planned: serializer.fromJson<bool?>(json['planned']),
      note: serializer.fromJson<String?>(json['note']),
      splitId: serializer.fromJson<String?>(json['splitId']),
      toVault: serializer.fromJson<bool>(json['toVault']),
      fromVault: serializer.fromJson<bool>(json['fromVault']),
      billId: serializer.fromJson<String?>(json['billId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(
        $EntriesTable.$convertertype.toJson(type),
      ),
      'amountCents': serializer.toJson<int>(amountCents),
      'localDate': serializer.toJson<LocalDate>(localDate),
      'createdAtUtc': serializer.toJson<DateTime>(createdAtUtc),
      'timeZoneId': serializer.toJson<String>(timeZoneId),
      'merchant': serializer.toJson<String?>(merchant),
      'categoryId': serializer.toJson<String?>(categoryId),
      'mood': serializer.toJson<String?>(
        $EntriesTable.$convertermoodn.toJson(mood),
      ),
      'planned': serializer.toJson<bool?>(planned),
      'note': serializer.toJson<String?>(note),
      'splitId': serializer.toJson<String?>(splitId),
      'toVault': serializer.toJson<bool>(toVault),
      'fromVault': serializer.toJson<bool>(fromVault),
      'billId': serializer.toJson<String?>(billId),
    };
  }

  EntryRow copyWith({
    String? id,
    EntryType? type,
    int? amountCents,
    LocalDate? localDate,
    DateTime? createdAtUtc,
    String? timeZoneId,
    Value<String?> merchant = const Value.absent(),
    Value<String?> categoryId = const Value.absent(),
    Value<Mood?> mood = const Value.absent(),
    Value<bool?> planned = const Value.absent(),
    Value<String?> note = const Value.absent(),
    Value<String?> splitId = const Value.absent(),
    bool? toVault,
    bool? fromVault,
    Value<String?> billId = const Value.absent(),
  }) => EntryRow(
    id: id ?? this.id,
    type: type ?? this.type,
    amountCents: amountCents ?? this.amountCents,
    localDate: localDate ?? this.localDate,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    timeZoneId: timeZoneId ?? this.timeZoneId,
    merchant: merchant.present ? merchant.value : this.merchant,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    mood: mood.present ? mood.value : this.mood,
    planned: planned.present ? planned.value : this.planned,
    note: note.present ? note.value : this.note,
    splitId: splitId.present ? splitId.value : this.splitId,
    toVault: toVault ?? this.toVault,
    fromVault: fromVault ?? this.fromVault,
    billId: billId.present ? billId.value : this.billId,
  );
  EntryRow copyWithCompanion(EntriesCompanion data) {
    return EntryRow(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      amountCents: data.amountCents.present
          ? data.amountCents.value
          : this.amountCents,
      localDate: data.localDate.present ? data.localDate.value : this.localDate,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      timeZoneId: data.timeZoneId.present
          ? data.timeZoneId.value
          : this.timeZoneId,
      merchant: data.merchant.present ? data.merchant.value : this.merchant,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      mood: data.mood.present ? data.mood.value : this.mood,
      planned: data.planned.present ? data.planned.value : this.planned,
      note: data.note.present ? data.note.value : this.note,
      splitId: data.splitId.present ? data.splitId.value : this.splitId,
      toVault: data.toVault.present ? data.toVault.value : this.toVault,
      fromVault: data.fromVault.present ? data.fromVault.value : this.fromVault,
      billId: data.billId.present ? data.billId.value : this.billId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntryRow(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('amountCents: $amountCents, ')
          ..write('localDate: $localDate, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('timeZoneId: $timeZoneId, ')
          ..write('merchant: $merchant, ')
          ..write('categoryId: $categoryId, ')
          ..write('mood: $mood, ')
          ..write('planned: $planned, ')
          ..write('note: $note, ')
          ..write('splitId: $splitId, ')
          ..write('toVault: $toVault, ')
          ..write('fromVault: $fromVault, ')
          ..write('billId: $billId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    amountCents,
    localDate,
    createdAtUtc,
    timeZoneId,
    merchant,
    categoryId,
    mood,
    planned,
    note,
    splitId,
    toVault,
    fromVault,
    billId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntryRow &&
          other.id == this.id &&
          other.type == this.type &&
          other.amountCents == this.amountCents &&
          other.localDate == this.localDate &&
          other.createdAtUtc == this.createdAtUtc &&
          other.timeZoneId == this.timeZoneId &&
          other.merchant == this.merchant &&
          other.categoryId == this.categoryId &&
          other.mood == this.mood &&
          other.planned == this.planned &&
          other.note == this.note &&
          other.splitId == this.splitId &&
          other.toVault == this.toVault &&
          other.fromVault == this.fromVault &&
          other.billId == this.billId);
}

class EntriesCompanion extends UpdateCompanion<EntryRow> {
  final Value<String> id;
  final Value<EntryType> type;
  final Value<int> amountCents;
  final Value<LocalDate> localDate;
  final Value<DateTime> createdAtUtc;
  final Value<String> timeZoneId;
  final Value<String?> merchant;
  final Value<String?> categoryId;
  final Value<Mood?> mood;
  final Value<bool?> planned;
  final Value<String?> note;
  final Value<String?> splitId;
  final Value<bool> toVault;
  final Value<bool> fromVault;
  final Value<String?> billId;
  final Value<int> rowid;
  const EntriesCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.localDate = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.timeZoneId = const Value.absent(),
    this.merchant = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.mood = const Value.absent(),
    this.planned = const Value.absent(),
    this.note = const Value.absent(),
    this.splitId = const Value.absent(),
    this.toVault = const Value.absent(),
    this.fromVault = const Value.absent(),
    this.billId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EntriesCompanion.insert({
    required String id,
    required EntryType type,
    required int amountCents,
    required LocalDate localDate,
    required DateTime createdAtUtc,
    required String timeZoneId,
    this.merchant = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.mood = const Value.absent(),
    this.planned = const Value.absent(),
    this.note = const Value.absent(),
    this.splitId = const Value.absent(),
    this.toVault = const Value.absent(),
    this.fromVault = const Value.absent(),
    this.billId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       amountCents = Value(amountCents),
       localDate = Value(localDate),
       createdAtUtc = Value(createdAtUtc),
       timeZoneId = Value(timeZoneId);
  static Insertable<EntryRow> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<int>? amountCents,
    Expression<String>? localDate,
    Expression<DateTime>? createdAtUtc,
    Expression<String>? timeZoneId,
    Expression<String>? merchant,
    Expression<String>? categoryId,
    Expression<String>? mood,
    Expression<bool>? planned,
    Expression<String>? note,
    Expression<String>? splitId,
    Expression<bool>? toVault,
    Expression<bool>? fromVault,
    Expression<String>? billId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (amountCents != null) 'amount_cents': amountCents,
      if (localDate != null) 'local_date': localDate,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (timeZoneId != null) 'time_zone_id': timeZoneId,
      if (merchant != null) 'merchant': merchant,
      if (categoryId != null) 'category_id': categoryId,
      if (mood != null) 'mood': mood,
      if (planned != null) 'planned': planned,
      if (note != null) 'note': note,
      if (splitId != null) 'split_id': splitId,
      if (toVault != null) 'to_vault': toVault,
      if (fromVault != null) 'from_vault': fromVault,
      if (billId != null) 'bill_id': billId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EntriesCompanion copyWith({
    Value<String>? id,
    Value<EntryType>? type,
    Value<int>? amountCents,
    Value<LocalDate>? localDate,
    Value<DateTime>? createdAtUtc,
    Value<String>? timeZoneId,
    Value<String?>? merchant,
    Value<String?>? categoryId,
    Value<Mood?>? mood,
    Value<bool?>? planned,
    Value<String?>? note,
    Value<String?>? splitId,
    Value<bool>? toVault,
    Value<bool>? fromVault,
    Value<String?>? billId,
    Value<int>? rowid,
  }) {
    return EntriesCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      amountCents: amountCents ?? this.amountCents,
      localDate: localDate ?? this.localDate,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      timeZoneId: timeZoneId ?? this.timeZoneId,
      merchant: merchant ?? this.merchant,
      categoryId: categoryId ?? this.categoryId,
      mood: mood ?? this.mood,
      planned: planned ?? this.planned,
      note: note ?? this.note,
      splitId: splitId ?? this.splitId,
      toVault: toVault ?? this.toVault,
      fromVault: fromVault ?? this.fromVault,
      billId: billId ?? this.billId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $EntriesTable.$convertertype.toSql(type.value),
      );
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    if (localDate.present) {
      map['local_date'] = Variable<String>(
        $EntriesTable.$converterlocalDate.toSql(localDate.value),
      );
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<DateTime>(createdAtUtc.value);
    }
    if (timeZoneId.present) {
      map['time_zone_id'] = Variable<String>(timeZoneId.value);
    }
    if (merchant.present) {
      map['merchant'] = Variable<String>(merchant.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (mood.present) {
      map['mood'] = Variable<String>(
        $EntriesTable.$convertermoodn.toSql(mood.value),
      );
    }
    if (planned.present) {
      map['planned'] = Variable<bool>(planned.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (splitId.present) {
      map['split_id'] = Variable<String>(splitId.value);
    }
    if (toVault.present) {
      map['to_vault'] = Variable<bool>(toVault.value);
    }
    if (fromVault.present) {
      map['from_vault'] = Variable<bool>(fromVault.value);
    }
    if (billId.present) {
      map['bill_id'] = Variable<String>(billId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntriesCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('amountCents: $amountCents, ')
          ..write('localDate: $localDate, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('timeZoneId: $timeZoneId, ')
          ..write('merchant: $merchant, ')
          ..write('categoryId: $categoryId, ')
          ..write('mood: $mood, ')
          ..write('planned: $planned, ')
          ..write('note: $note, ')
          ..write('splitId: $splitId, ')
          ..write('toVault: $toVault, ')
          ..write('fromVault: $fromVault, ')
          ..write('billId: $billId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BillsTable extends Bills with TableInfo<$BillsTable, BillRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BillsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountCentsMeta = const VerificationMeta(
    'amountCents',
  );
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
    'amount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Recurrence, String> recurrence =
      GeneratedColumn<String>(
        'recurrence',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Recurrence>($BillsTable.$converterrecurrence);
  @override
  late final GeneratedColumnWithTypeConverter<LocalDate, String> dueDate =
      GeneratedColumn<String>(
        'due_date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LocalDate>($BillsTable.$converterdueDate);
  static const VerificationMeta _isEstimateMeta = const VerificationMeta(
    'isEstimate',
  );
  @override
  late final GeneratedColumn<bool> isEstimate = GeneratedColumn<bool>(
    'is_estimate',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_estimate" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isSubscriptionMeta = const VerificationMeta(
    'isSubscription',
  );
  @override
  late final GeneratedColumn<bool> isSubscription = GeneratedColumn<bool>(
    'is_subscription',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_subscription" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _needsReviewMeta = const VerificationMeta(
    'needsReview',
  );
  @override
  late final GeneratedColumn<bool> needsReview = GeneratedColumn<bool>(
    'needs_review',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("needs_review" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<LocalDate?, String> lastPaidOn =
      GeneratedColumn<String>(
        'last_paid_on',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<LocalDate?>($BillsTable.$converterlastPaidOnn);
  static const VerificationMeta _previousAmountCentsMeta =
      const VerificationMeta('previousAmountCents');
  @override
  late final GeneratedColumn<int> previousAmountCents = GeneratedColumn<int>(
    'previous_amount_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    amountCents,
    recurrence,
    dueDate,
    isEstimate,
    isSubscription,
    needsReview,
    lastPaidOn,
    previousAmountCents,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bills';
  @override
  VerificationContext validateIntegrity(
    Insertable<BillRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
        _amountCentsMeta,
        amountCents.isAcceptableOrUnknown(
          data['amount_cents']!,
          _amountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountCentsMeta);
    }
    if (data.containsKey('is_estimate')) {
      context.handle(
        _isEstimateMeta,
        isEstimate.isAcceptableOrUnknown(data['is_estimate']!, _isEstimateMeta),
      );
    }
    if (data.containsKey('is_subscription')) {
      context.handle(
        _isSubscriptionMeta,
        isSubscription.isAcceptableOrUnknown(
          data['is_subscription']!,
          _isSubscriptionMeta,
        ),
      );
    }
    if (data.containsKey('needs_review')) {
      context.handle(
        _needsReviewMeta,
        needsReview.isAcceptableOrUnknown(
          data['needs_review']!,
          _needsReviewMeta,
        ),
      );
    }
    if (data.containsKey('previous_amount_cents')) {
      context.handle(
        _previousAmountCentsMeta,
        previousAmountCents.isAcceptableOrUnknown(
          data['previous_amount_cents']!,
          _previousAmountCentsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BillRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BillRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      amountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_cents'],
      )!,
      recurrence: $BillsTable.$converterrecurrence.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}recurrence'],
        )!,
      ),
      dueDate: $BillsTable.$converterdueDate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}due_date'],
        )!,
      ),
      isEstimate: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_estimate'],
      )!,
      isSubscription: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_subscription'],
      )!,
      needsReview: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}needs_review'],
      )!,
      lastPaidOn: $BillsTable.$converterlastPaidOnn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}last_paid_on'],
        ),
      ),
      previousAmountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}previous_amount_cents'],
      ),
    );
  }

  @override
  $BillsTable createAlias(String alias) {
    return $BillsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Recurrence, String, String> $converterrecurrence =
      const EnumNameConverter<Recurrence>(Recurrence.values);
  static TypeConverter<LocalDate, String> $converterdueDate =
      const LocalDateConverter();
  static TypeConverter<LocalDate, String> $converterlastPaidOn =
      const LocalDateConverter();
  static TypeConverter<LocalDate?, String?> $converterlastPaidOnn =
      NullAwareTypeConverter.wrap($converterlastPaidOn);
}

class BillRow extends DataClass implements Insertable<BillRow> {
  final String id;
  final String name;
  final int amountCents;
  final Recurrence recurrence;
  final LocalDate dueDate;
  final bool isEstimate;
  final bool isSubscription;
  final bool needsReview;

  /// v2: was `paid_on` ("this occurrence is paid"); now when the most
  /// recent occurrence was paid, with [dueDate] the next unpaid one.
  final LocalDate? lastPaidOn;
  final int? previousAmountCents;
  const BillRow({
    required this.id,
    required this.name,
    required this.amountCents,
    required this.recurrence,
    required this.dueDate,
    required this.isEstimate,
    required this.isSubscription,
    required this.needsReview,
    this.lastPaidOn,
    this.previousAmountCents,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['amount_cents'] = Variable<int>(amountCents);
    {
      map['recurrence'] = Variable<String>(
        $BillsTable.$converterrecurrence.toSql(recurrence),
      );
    }
    {
      map['due_date'] = Variable<String>(
        $BillsTable.$converterdueDate.toSql(dueDate),
      );
    }
    map['is_estimate'] = Variable<bool>(isEstimate);
    map['is_subscription'] = Variable<bool>(isSubscription);
    map['needs_review'] = Variable<bool>(needsReview);
    if (!nullToAbsent || lastPaidOn != null) {
      map['last_paid_on'] = Variable<String>(
        $BillsTable.$converterlastPaidOnn.toSql(lastPaidOn),
      );
    }
    if (!nullToAbsent || previousAmountCents != null) {
      map['previous_amount_cents'] = Variable<int>(previousAmountCents);
    }
    return map;
  }

  BillsCompanion toCompanion(bool nullToAbsent) {
    return BillsCompanion(
      id: Value(id),
      name: Value(name),
      amountCents: Value(amountCents),
      recurrence: Value(recurrence),
      dueDate: Value(dueDate),
      isEstimate: Value(isEstimate),
      isSubscription: Value(isSubscription),
      needsReview: Value(needsReview),
      lastPaidOn: lastPaidOn == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPaidOn),
      previousAmountCents: previousAmountCents == null && nullToAbsent
          ? const Value.absent()
          : Value(previousAmountCents),
    );
  }

  factory BillRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BillRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      amountCents: serializer.fromJson<int>(json['amountCents']),
      recurrence: $BillsTable.$converterrecurrence.fromJson(
        serializer.fromJson<String>(json['recurrence']),
      ),
      dueDate: serializer.fromJson<LocalDate>(json['dueDate']),
      isEstimate: serializer.fromJson<bool>(json['isEstimate']),
      isSubscription: serializer.fromJson<bool>(json['isSubscription']),
      needsReview: serializer.fromJson<bool>(json['needsReview']),
      lastPaidOn: serializer.fromJson<LocalDate?>(json['lastPaidOn']),
      previousAmountCents: serializer.fromJson<int?>(
        json['previousAmountCents'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'amountCents': serializer.toJson<int>(amountCents),
      'recurrence': serializer.toJson<String>(
        $BillsTable.$converterrecurrence.toJson(recurrence),
      ),
      'dueDate': serializer.toJson<LocalDate>(dueDate),
      'isEstimate': serializer.toJson<bool>(isEstimate),
      'isSubscription': serializer.toJson<bool>(isSubscription),
      'needsReview': serializer.toJson<bool>(needsReview),
      'lastPaidOn': serializer.toJson<LocalDate?>(lastPaidOn),
      'previousAmountCents': serializer.toJson<int?>(previousAmountCents),
    };
  }

  BillRow copyWith({
    String? id,
    String? name,
    int? amountCents,
    Recurrence? recurrence,
    LocalDate? dueDate,
    bool? isEstimate,
    bool? isSubscription,
    bool? needsReview,
    Value<LocalDate?> lastPaidOn = const Value.absent(),
    Value<int?> previousAmountCents = const Value.absent(),
  }) => BillRow(
    id: id ?? this.id,
    name: name ?? this.name,
    amountCents: amountCents ?? this.amountCents,
    recurrence: recurrence ?? this.recurrence,
    dueDate: dueDate ?? this.dueDate,
    isEstimate: isEstimate ?? this.isEstimate,
    isSubscription: isSubscription ?? this.isSubscription,
    needsReview: needsReview ?? this.needsReview,
    lastPaidOn: lastPaidOn.present ? lastPaidOn.value : this.lastPaidOn,
    previousAmountCents: previousAmountCents.present
        ? previousAmountCents.value
        : this.previousAmountCents,
  );
  BillRow copyWithCompanion(BillsCompanion data) {
    return BillRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      amountCents: data.amountCents.present
          ? data.amountCents.value
          : this.amountCents,
      recurrence: data.recurrence.present
          ? data.recurrence.value
          : this.recurrence,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      isEstimate: data.isEstimate.present
          ? data.isEstimate.value
          : this.isEstimate,
      isSubscription: data.isSubscription.present
          ? data.isSubscription.value
          : this.isSubscription,
      needsReview: data.needsReview.present
          ? data.needsReview.value
          : this.needsReview,
      lastPaidOn: data.lastPaidOn.present
          ? data.lastPaidOn.value
          : this.lastPaidOn,
      previousAmountCents: data.previousAmountCents.present
          ? data.previousAmountCents.value
          : this.previousAmountCents,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BillRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('amountCents: $amountCents, ')
          ..write('recurrence: $recurrence, ')
          ..write('dueDate: $dueDate, ')
          ..write('isEstimate: $isEstimate, ')
          ..write('isSubscription: $isSubscription, ')
          ..write('needsReview: $needsReview, ')
          ..write('lastPaidOn: $lastPaidOn, ')
          ..write('previousAmountCents: $previousAmountCents')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    amountCents,
    recurrence,
    dueDate,
    isEstimate,
    isSubscription,
    needsReview,
    lastPaidOn,
    previousAmountCents,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BillRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.amountCents == this.amountCents &&
          other.recurrence == this.recurrence &&
          other.dueDate == this.dueDate &&
          other.isEstimate == this.isEstimate &&
          other.isSubscription == this.isSubscription &&
          other.needsReview == this.needsReview &&
          other.lastPaidOn == this.lastPaidOn &&
          other.previousAmountCents == this.previousAmountCents);
}

class BillsCompanion extends UpdateCompanion<BillRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> amountCents;
  final Value<Recurrence> recurrence;
  final Value<LocalDate> dueDate;
  final Value<bool> isEstimate;
  final Value<bool> isSubscription;
  final Value<bool> needsReview;
  final Value<LocalDate?> lastPaidOn;
  final Value<int?> previousAmountCents;
  final Value<int> rowid;
  const BillsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.recurrence = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.isEstimate = const Value.absent(),
    this.isSubscription = const Value.absent(),
    this.needsReview = const Value.absent(),
    this.lastPaidOn = const Value.absent(),
    this.previousAmountCents = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BillsCompanion.insert({
    required String id,
    required String name,
    required int amountCents,
    required Recurrence recurrence,
    required LocalDate dueDate,
    this.isEstimate = const Value.absent(),
    this.isSubscription = const Value.absent(),
    this.needsReview = const Value.absent(),
    this.lastPaidOn = const Value.absent(),
    this.previousAmountCents = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       amountCents = Value(amountCents),
       recurrence = Value(recurrence),
       dueDate = Value(dueDate);
  static Insertable<BillRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? amountCents,
    Expression<String>? recurrence,
    Expression<String>? dueDate,
    Expression<bool>? isEstimate,
    Expression<bool>? isSubscription,
    Expression<bool>? needsReview,
    Expression<String>? lastPaidOn,
    Expression<int>? previousAmountCents,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (amountCents != null) 'amount_cents': amountCents,
      if (recurrence != null) 'recurrence': recurrence,
      if (dueDate != null) 'due_date': dueDate,
      if (isEstimate != null) 'is_estimate': isEstimate,
      if (isSubscription != null) 'is_subscription': isSubscription,
      if (needsReview != null) 'needs_review': needsReview,
      if (lastPaidOn != null) 'last_paid_on': lastPaidOn,
      if (previousAmountCents != null)
        'previous_amount_cents': previousAmountCents,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BillsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? amountCents,
    Value<Recurrence>? recurrence,
    Value<LocalDate>? dueDate,
    Value<bool>? isEstimate,
    Value<bool>? isSubscription,
    Value<bool>? needsReview,
    Value<LocalDate?>? lastPaidOn,
    Value<int?>? previousAmountCents,
    Value<int>? rowid,
  }) {
    return BillsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      amountCents: amountCents ?? this.amountCents,
      recurrence: recurrence ?? this.recurrence,
      dueDate: dueDate ?? this.dueDate,
      isEstimate: isEstimate ?? this.isEstimate,
      isSubscription: isSubscription ?? this.isSubscription,
      needsReview: needsReview ?? this.needsReview,
      lastPaidOn: lastPaidOn ?? this.lastPaidOn,
      previousAmountCents: previousAmountCents ?? this.previousAmountCents,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    if (recurrence.present) {
      map['recurrence'] = Variable<String>(
        $BillsTable.$converterrecurrence.toSql(recurrence.value),
      );
    }
    if (dueDate.present) {
      map['due_date'] = Variable<String>(
        $BillsTable.$converterdueDate.toSql(dueDate.value),
      );
    }
    if (isEstimate.present) {
      map['is_estimate'] = Variable<bool>(isEstimate.value);
    }
    if (isSubscription.present) {
      map['is_subscription'] = Variable<bool>(isSubscription.value);
    }
    if (needsReview.present) {
      map['needs_review'] = Variable<bool>(needsReview.value);
    }
    if (lastPaidOn.present) {
      map['last_paid_on'] = Variable<String>(
        $BillsTable.$converterlastPaidOnn.toSql(lastPaidOn.value),
      );
    }
    if (previousAmountCents.present) {
      map['previous_amount_cents'] = Variable<int>(previousAmountCents.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BillsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('amountCents: $amountCents, ')
          ..write('recurrence: $recurrence, ')
          ..write('dueDate: $dueDate, ')
          ..write('isEstimate: $isEstimate, ')
          ..write('isSubscription: $isSubscription, ')
          ..write('needsReview: $needsReview, ')
          ..write('lastPaidOn: $lastPaidOn, ')
          ..write('previousAmountCents: $previousAmountCents, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GoalsTable extends Goals with TableInfo<$GoalsTable, GoalRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<GoalKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<GoalKind>($GoalsTable.$converterkind);
  static const VerificationMeta _targetCentsMeta = const VerificationMeta(
    'targetCents',
  );
  @override
  late final GeneratedColumn<int> targetCents = GeneratedColumn<int>(
    'target_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _savedCentsMeta = const VerificationMeta(
    'savedCents',
  );
  @override
  late final GeneratedColumn<int> savedCents = GeneratedColumn<int>(
    'saved_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dailySetAsideCentsMeta =
      const VerificationMeta('dailySetAsideCents');
  @override
  late final GeneratedColumn<int> dailySetAsideCents = GeneratedColumn<int>(
    'daily_set_aside_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<LocalDate?, String> targetDate =
      GeneratedColumn<String>(
        'target_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<LocalDate?>($GoalsTable.$convertertargetDaten);
  static const VerificationMeta _pausedMeta = const VerificationMeta('paused');
  @override
  late final GeneratedColumn<bool> paused = GeneratedColumn<bool>(
    'paused',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("paused" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<LocalDate?, String> createdOn =
      GeneratedColumn<String>(
        'created_on',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<LocalDate?>($GoalsTable.$convertercreatedOnn);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    kind,
    targetCents,
    savedCents,
    dailySetAsideCents,
    targetDate,
    paused,
    sortOrder,
    createdOn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<GoalRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('target_cents')) {
      context.handle(
        _targetCentsMeta,
        targetCents.isAcceptableOrUnknown(
          data['target_cents']!,
          _targetCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetCentsMeta);
    }
    if (data.containsKey('saved_cents')) {
      context.handle(
        _savedCentsMeta,
        savedCents.isAcceptableOrUnknown(data['saved_cents']!, _savedCentsMeta),
      );
    } else if (isInserting) {
      context.missing(_savedCentsMeta);
    }
    if (data.containsKey('daily_set_aside_cents')) {
      context.handle(
        _dailySetAsideCentsMeta,
        dailySetAsideCents.isAcceptableOrUnknown(
          data['daily_set_aside_cents']!,
          _dailySetAsideCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dailySetAsideCentsMeta);
    }
    if (data.containsKey('paused')) {
      context.handle(
        _pausedMeta,
        paused.isAcceptableOrUnknown(data['paused']!, _pausedMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GoalRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GoalRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: $GoalsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      targetCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_cents'],
      )!,
      savedCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}saved_cents'],
      )!,
      dailySetAsideCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_set_aside_cents'],
      )!,
      targetDate: $GoalsTable.$convertertargetDaten.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}target_date'],
        ),
      ),
      paused: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}paused'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdOn: $GoalsTable.$convertercreatedOnn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}created_on'],
        ),
      ),
    );
  }

  @override
  $GoalsTable createAlias(String alias) {
    return $GoalsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<GoalKind, String, String> $converterkind =
      const EnumNameConverter<GoalKind>(GoalKind.values);
  static TypeConverter<LocalDate, String> $convertertargetDate =
      const LocalDateConverter();
  static TypeConverter<LocalDate?, String?> $convertertargetDaten =
      NullAwareTypeConverter.wrap($convertertargetDate);
  static TypeConverter<LocalDate, String> $convertercreatedOn =
      const LocalDateConverter();
  static TypeConverter<LocalDate?, String?> $convertercreatedOnn =
      NullAwareTypeConverter.wrap($convertercreatedOn);
}

class GoalRow extends DataClass implements Insertable<GoalRow> {
  final String id;
  final String name;
  final GoalKind kind;
  final int targetCents;
  final int savedCents;
  final int dailySetAsideCents;
  final LocalDate? targetDate;
  final bool paused;
  final int sortOrder;
  final LocalDate? createdOn;
  const GoalRow({
    required this.id,
    required this.name,
    required this.kind,
    required this.targetCents,
    required this.savedCents,
    required this.dailySetAsideCents,
    this.targetDate,
    required this.paused,
    required this.sortOrder,
    this.createdOn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    {
      map['kind'] = Variable<String>($GoalsTable.$converterkind.toSql(kind));
    }
    map['target_cents'] = Variable<int>(targetCents);
    map['saved_cents'] = Variable<int>(savedCents);
    map['daily_set_aside_cents'] = Variable<int>(dailySetAsideCents);
    if (!nullToAbsent || targetDate != null) {
      map['target_date'] = Variable<String>(
        $GoalsTable.$convertertargetDaten.toSql(targetDate),
      );
    }
    map['paused'] = Variable<bool>(paused);
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || createdOn != null) {
      map['created_on'] = Variable<String>(
        $GoalsTable.$convertercreatedOnn.toSql(createdOn),
      );
    }
    return map;
  }

  GoalsCompanion toCompanion(bool nullToAbsent) {
    return GoalsCompanion(
      id: Value(id),
      name: Value(name),
      kind: Value(kind),
      targetCents: Value(targetCents),
      savedCents: Value(savedCents),
      dailySetAsideCents: Value(dailySetAsideCents),
      targetDate: targetDate == null && nullToAbsent
          ? const Value.absent()
          : Value(targetDate),
      paused: Value(paused),
      sortOrder: Value(sortOrder),
      createdOn: createdOn == null && nullToAbsent
          ? const Value.absent()
          : Value(createdOn),
    );
  }

  factory GoalRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GoalRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      kind: $GoalsTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      targetCents: serializer.fromJson<int>(json['targetCents']),
      savedCents: serializer.fromJson<int>(json['savedCents']),
      dailySetAsideCents: serializer.fromJson<int>(json['dailySetAsideCents']),
      targetDate: serializer.fromJson<LocalDate?>(json['targetDate']),
      paused: serializer.fromJson<bool>(json['paused']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdOn: serializer.fromJson<LocalDate?>(json['createdOn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(
        $GoalsTable.$converterkind.toJson(kind),
      ),
      'targetCents': serializer.toJson<int>(targetCents),
      'savedCents': serializer.toJson<int>(savedCents),
      'dailySetAsideCents': serializer.toJson<int>(dailySetAsideCents),
      'targetDate': serializer.toJson<LocalDate?>(targetDate),
      'paused': serializer.toJson<bool>(paused),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdOn': serializer.toJson<LocalDate?>(createdOn),
    };
  }

  GoalRow copyWith({
    String? id,
    String? name,
    GoalKind? kind,
    int? targetCents,
    int? savedCents,
    int? dailySetAsideCents,
    Value<LocalDate?> targetDate = const Value.absent(),
    bool? paused,
    int? sortOrder,
    Value<LocalDate?> createdOn = const Value.absent(),
  }) => GoalRow(
    id: id ?? this.id,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    targetCents: targetCents ?? this.targetCents,
    savedCents: savedCents ?? this.savedCents,
    dailySetAsideCents: dailySetAsideCents ?? this.dailySetAsideCents,
    targetDate: targetDate.present ? targetDate.value : this.targetDate,
    paused: paused ?? this.paused,
    sortOrder: sortOrder ?? this.sortOrder,
    createdOn: createdOn.present ? createdOn.value : this.createdOn,
  );
  GoalRow copyWithCompanion(GoalsCompanion data) {
    return GoalRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      targetCents: data.targetCents.present
          ? data.targetCents.value
          : this.targetCents,
      savedCents: data.savedCents.present
          ? data.savedCents.value
          : this.savedCents,
      dailySetAsideCents: data.dailySetAsideCents.present
          ? data.dailySetAsideCents.value
          : this.dailySetAsideCents,
      targetDate: data.targetDate.present
          ? data.targetDate.value
          : this.targetDate,
      paused: data.paused.present ? data.paused.value : this.paused,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdOn: data.createdOn.present ? data.createdOn.value : this.createdOn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GoalRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('targetCents: $targetCents, ')
          ..write('savedCents: $savedCents, ')
          ..write('dailySetAsideCents: $dailySetAsideCents, ')
          ..write('targetDate: $targetDate, ')
          ..write('paused: $paused, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdOn: $createdOn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    kind,
    targetCents,
    savedCents,
    dailySetAsideCents,
    targetDate,
    paused,
    sortOrder,
    createdOn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoalRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.targetCents == this.targetCents &&
          other.savedCents == this.savedCents &&
          other.dailySetAsideCents == this.dailySetAsideCents &&
          other.targetDate == this.targetDate &&
          other.paused == this.paused &&
          other.sortOrder == this.sortOrder &&
          other.createdOn == this.createdOn);
}

class GoalsCompanion extends UpdateCompanion<GoalRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<GoalKind> kind;
  final Value<int> targetCents;
  final Value<int> savedCents;
  final Value<int> dailySetAsideCents;
  final Value<LocalDate?> targetDate;
  final Value<bool> paused;
  final Value<int> sortOrder;
  final Value<LocalDate?> createdOn;
  final Value<int> rowid;
  const GoalsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.targetCents = const Value.absent(),
    this.savedCents = const Value.absent(),
    this.dailySetAsideCents = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.paused = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdOn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GoalsCompanion.insert({
    required String id,
    required String name,
    required GoalKind kind,
    required int targetCents,
    required int savedCents,
    required int dailySetAsideCents,
    this.targetDate = const Value.absent(),
    this.paused = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdOn = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       kind = Value(kind),
       targetCents = Value(targetCents),
       savedCents = Value(savedCents),
       dailySetAsideCents = Value(dailySetAsideCents);
  static Insertable<GoalRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<int>? targetCents,
    Expression<int>? savedCents,
    Expression<int>? dailySetAsideCents,
    Expression<String>? targetDate,
    Expression<bool>? paused,
    Expression<int>? sortOrder,
    Expression<String>? createdOn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (targetCents != null) 'target_cents': targetCents,
      if (savedCents != null) 'saved_cents': savedCents,
      if (dailySetAsideCents != null)
        'daily_set_aside_cents': dailySetAsideCents,
      if (targetDate != null) 'target_date': targetDate,
      if (paused != null) 'paused': paused,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdOn != null) 'created_on': createdOn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GoalsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<GoalKind>? kind,
    Value<int>? targetCents,
    Value<int>? savedCents,
    Value<int>? dailySetAsideCents,
    Value<LocalDate?>? targetDate,
    Value<bool>? paused,
    Value<int>? sortOrder,
    Value<LocalDate?>? createdOn,
    Value<int>? rowid,
  }) {
    return GoalsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      targetCents: targetCents ?? this.targetCents,
      savedCents: savedCents ?? this.savedCents,
      dailySetAsideCents: dailySetAsideCents ?? this.dailySetAsideCents,
      targetDate: targetDate ?? this.targetDate,
      paused: paused ?? this.paused,
      sortOrder: sortOrder ?? this.sortOrder,
      createdOn: createdOn ?? this.createdOn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $GoalsTable.$converterkind.toSql(kind.value),
      );
    }
    if (targetCents.present) {
      map['target_cents'] = Variable<int>(targetCents.value);
    }
    if (savedCents.present) {
      map['saved_cents'] = Variable<int>(savedCents.value);
    }
    if (dailySetAsideCents.present) {
      map['daily_set_aside_cents'] = Variable<int>(dailySetAsideCents.value);
    }
    if (targetDate.present) {
      map['target_date'] = Variable<String>(
        $GoalsTable.$convertertargetDaten.toSql(targetDate.value),
      );
    }
    if (paused.present) {
      map['paused'] = Variable<bool>(paused.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdOn.present) {
      map['created_on'] = Variable<String>(
        $GoalsTable.$convertercreatedOnn.toSql(createdOn.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('targetCents: $targetCents, ')
          ..write('savedCents: $savedCents, ')
          ..write('dailySetAsideCents: $dailySetAsideCents, ')
          ..write('targetDate: $targetDate, ')
          ..write('paused: $paused, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdOn: $createdOn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VaultsTable extends Vaults with TableInfo<$VaultsTable, VaultRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VaultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _openingBalanceCentsMeta =
      const VerificationMeta('openingBalanceCents');
  @override
  late final GeneratedColumn<int> openingBalanceCents = GeneratedColumn<int>(
    'opening_balance_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _steadyPayWeeklyCentsMeta =
      const VerificationMeta('steadyPayWeeklyCents');
  @override
  late final GeneratedColumn<int> steadyPayWeeklyCents = GeneratedColumn<int>(
    'steady_pay_weekly_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetWeeksMeta = const VerificationMeta(
    'targetWeeks',
  );
  @override
  late final GeneratedColumn<int> targetWeeks = GeneratedColumn<int>(
    'target_weeks',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(4),
  );
  @override
  late final GeneratedColumnWithTypeConverter<LocalDate?, String>
  lastReleaseDate = GeneratedColumn<String>(
    'last_release_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<LocalDate?>($VaultsTable.$converterlastReleaseDaten);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    openingBalanceCents,
    steadyPayWeeklyCents,
    targetWeeks,
    lastReleaseDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vaults';
  @override
  VerificationContext validateIntegrity(
    Insertable<VaultRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('opening_balance_cents')) {
      context.handle(
        _openingBalanceCentsMeta,
        openingBalanceCents.isAcceptableOrUnknown(
          data['opening_balance_cents']!,
          _openingBalanceCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_openingBalanceCentsMeta);
    }
    if (data.containsKey('steady_pay_weekly_cents')) {
      context.handle(
        _steadyPayWeeklyCentsMeta,
        steadyPayWeeklyCents.isAcceptableOrUnknown(
          data['steady_pay_weekly_cents']!,
          _steadyPayWeeklyCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_steadyPayWeeklyCentsMeta);
    }
    if (data.containsKey('target_weeks')) {
      context.handle(
        _targetWeeksMeta,
        targetWeeks.isAcceptableOrUnknown(
          data['target_weeks']!,
          _targetWeeksMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VaultRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VaultRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      openingBalanceCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}opening_balance_cents'],
      )!,
      steadyPayWeeklyCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}steady_pay_weekly_cents'],
      )!,
      targetWeeks: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_weeks'],
      )!,
      lastReleaseDate: $VaultsTable.$converterlastReleaseDaten.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}last_release_date'],
        ),
      ),
    );
  }

  @override
  $VaultsTable createAlias(String alias) {
    return $VaultsTable(attachedDatabase, alias);
  }

  static TypeConverter<LocalDate, String> $converterlastReleaseDate =
      const LocalDateConverter();
  static TypeConverter<LocalDate?, String?> $converterlastReleaseDaten =
      NullAwareTypeConverter.wrap($converterlastReleaseDate);
}

class VaultRow extends DataClass implements Insertable<VaultRow> {
  final int id;
  final int openingBalanceCents;
  final int steadyPayWeeklyCents;
  final int targetWeeks;

  /// v2: Monday of the latest steady-pay release.
  final LocalDate? lastReleaseDate;
  const VaultRow({
    required this.id,
    required this.openingBalanceCents,
    required this.steadyPayWeeklyCents,
    required this.targetWeeks,
    this.lastReleaseDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['opening_balance_cents'] = Variable<int>(openingBalanceCents);
    map['steady_pay_weekly_cents'] = Variable<int>(steadyPayWeeklyCents);
    map['target_weeks'] = Variable<int>(targetWeeks);
    if (!nullToAbsent || lastReleaseDate != null) {
      map['last_release_date'] = Variable<String>(
        $VaultsTable.$converterlastReleaseDaten.toSql(lastReleaseDate),
      );
    }
    return map;
  }

  VaultsCompanion toCompanion(bool nullToAbsent) {
    return VaultsCompanion(
      id: Value(id),
      openingBalanceCents: Value(openingBalanceCents),
      steadyPayWeeklyCents: Value(steadyPayWeeklyCents),
      targetWeeks: Value(targetWeeks),
      lastReleaseDate: lastReleaseDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReleaseDate),
    );
  }

  factory VaultRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VaultRow(
      id: serializer.fromJson<int>(json['id']),
      openingBalanceCents: serializer.fromJson<int>(
        json['openingBalanceCents'],
      ),
      steadyPayWeeklyCents: serializer.fromJson<int>(
        json['steadyPayWeeklyCents'],
      ),
      targetWeeks: serializer.fromJson<int>(json['targetWeeks']),
      lastReleaseDate: serializer.fromJson<LocalDate?>(json['lastReleaseDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'openingBalanceCents': serializer.toJson<int>(openingBalanceCents),
      'steadyPayWeeklyCents': serializer.toJson<int>(steadyPayWeeklyCents),
      'targetWeeks': serializer.toJson<int>(targetWeeks),
      'lastReleaseDate': serializer.toJson<LocalDate?>(lastReleaseDate),
    };
  }

  VaultRow copyWith({
    int? id,
    int? openingBalanceCents,
    int? steadyPayWeeklyCents,
    int? targetWeeks,
    Value<LocalDate?> lastReleaseDate = const Value.absent(),
  }) => VaultRow(
    id: id ?? this.id,
    openingBalanceCents: openingBalanceCents ?? this.openingBalanceCents,
    steadyPayWeeklyCents: steadyPayWeeklyCents ?? this.steadyPayWeeklyCents,
    targetWeeks: targetWeeks ?? this.targetWeeks,
    lastReleaseDate: lastReleaseDate.present
        ? lastReleaseDate.value
        : this.lastReleaseDate,
  );
  VaultRow copyWithCompanion(VaultsCompanion data) {
    return VaultRow(
      id: data.id.present ? data.id.value : this.id,
      openingBalanceCents: data.openingBalanceCents.present
          ? data.openingBalanceCents.value
          : this.openingBalanceCents,
      steadyPayWeeklyCents: data.steadyPayWeeklyCents.present
          ? data.steadyPayWeeklyCents.value
          : this.steadyPayWeeklyCents,
      targetWeeks: data.targetWeeks.present
          ? data.targetWeeks.value
          : this.targetWeeks,
      lastReleaseDate: data.lastReleaseDate.present
          ? data.lastReleaseDate.value
          : this.lastReleaseDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VaultRow(')
          ..write('id: $id, ')
          ..write('openingBalanceCents: $openingBalanceCents, ')
          ..write('steadyPayWeeklyCents: $steadyPayWeeklyCents, ')
          ..write('targetWeeks: $targetWeeks, ')
          ..write('lastReleaseDate: $lastReleaseDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    openingBalanceCents,
    steadyPayWeeklyCents,
    targetWeeks,
    lastReleaseDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VaultRow &&
          other.id == this.id &&
          other.openingBalanceCents == this.openingBalanceCents &&
          other.steadyPayWeeklyCents == this.steadyPayWeeklyCents &&
          other.targetWeeks == this.targetWeeks &&
          other.lastReleaseDate == this.lastReleaseDate);
}

class VaultsCompanion extends UpdateCompanion<VaultRow> {
  final Value<int> id;
  final Value<int> openingBalanceCents;
  final Value<int> steadyPayWeeklyCents;
  final Value<int> targetWeeks;
  final Value<LocalDate?> lastReleaseDate;
  const VaultsCompanion({
    this.id = const Value.absent(),
    this.openingBalanceCents = const Value.absent(),
    this.steadyPayWeeklyCents = const Value.absent(),
    this.targetWeeks = const Value.absent(),
    this.lastReleaseDate = const Value.absent(),
  });
  VaultsCompanion.insert({
    this.id = const Value.absent(),
    required int openingBalanceCents,
    required int steadyPayWeeklyCents,
    this.targetWeeks = const Value.absent(),
    this.lastReleaseDate = const Value.absent(),
  }) : openingBalanceCents = Value(openingBalanceCents),
       steadyPayWeeklyCents = Value(steadyPayWeeklyCents);
  static Insertable<VaultRow> custom({
    Expression<int>? id,
    Expression<int>? openingBalanceCents,
    Expression<int>? steadyPayWeeklyCents,
    Expression<int>? targetWeeks,
    Expression<String>? lastReleaseDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (openingBalanceCents != null)
        'opening_balance_cents': openingBalanceCents,
      if (steadyPayWeeklyCents != null)
        'steady_pay_weekly_cents': steadyPayWeeklyCents,
      if (targetWeeks != null) 'target_weeks': targetWeeks,
      if (lastReleaseDate != null) 'last_release_date': lastReleaseDate,
    });
  }

  VaultsCompanion copyWith({
    Value<int>? id,
    Value<int>? openingBalanceCents,
    Value<int>? steadyPayWeeklyCents,
    Value<int>? targetWeeks,
    Value<LocalDate?>? lastReleaseDate,
  }) {
    return VaultsCompanion(
      id: id ?? this.id,
      openingBalanceCents: openingBalanceCents ?? this.openingBalanceCents,
      steadyPayWeeklyCents: steadyPayWeeklyCents ?? this.steadyPayWeeklyCents,
      targetWeeks: targetWeeks ?? this.targetWeeks,
      lastReleaseDate: lastReleaseDate ?? this.lastReleaseDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (openingBalanceCents.present) {
      map['opening_balance_cents'] = Variable<int>(openingBalanceCents.value);
    }
    if (steadyPayWeeklyCents.present) {
      map['steady_pay_weekly_cents'] = Variable<int>(
        steadyPayWeeklyCents.value,
      );
    }
    if (targetWeeks.present) {
      map['target_weeks'] = Variable<int>(targetWeeks.value);
    }
    if (lastReleaseDate.present) {
      map['last_release_date'] = Variable<String>(
        $VaultsTable.$converterlastReleaseDaten.toSql(lastReleaseDate.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VaultsCompanion(')
          ..write('id: $id, ')
          ..write('openingBalanceCents: $openingBalanceCents, ')
          ..write('steadyPayWeeklyCents: $steadyPayWeeklyCents, ')
          ..write('targetWeeks: $targetWeeks, ')
          ..write('lastReleaseDate: $lastReleaseDate')
          ..write(')'))
        .toString();
  }
}

class $SplitsTable extends Splits with TableInfo<$SplitsTable, SplitRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SplitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _personNameMeta = const VerificationMeta(
    'personName',
  );
  @override
  late final GeneratedColumn<String> personName = GeneratedColumn<String>(
    'person_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yourSharePercentMeta = const VerificationMeta(
    'yourSharePercent',
  );
  @override
  late final GeneratedColumn<int> yourSharePercent = GeneratedColumn<int>(
    'your_share_percent',
    aliasedName,
    false,
    check: () => ComparableExpr(yourSharePercent).isBetweenValues(0, 100),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SplitMethod, String> method =
      GeneratedColumn<String>(
        'method',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SplitMethod>($SplitsTable.$convertermethod);
  @override
  late final GeneratedColumnWithTypeConverter<LocalDate?, String> lastSettled =
      GeneratedColumn<String>(
        'last_settled',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<LocalDate?>($SplitsTable.$converterlastSettledn);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    personName,
    yourSharePercent,
    method,
    lastSettled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'splits';
  @override
  VerificationContext validateIntegrity(
    Insertable<SplitRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('person_name')) {
      context.handle(
        _personNameMeta,
        personName.isAcceptableOrUnknown(data['person_name']!, _personNameMeta),
      );
    } else if (isInserting) {
      context.missing(_personNameMeta);
    }
    if (data.containsKey('your_share_percent')) {
      context.handle(
        _yourSharePercentMeta,
        yourSharePercent.isAcceptableOrUnknown(
          data['your_share_percent']!,
          _yourSharePercentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_yourSharePercentMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SplitRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SplitRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      personName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person_name'],
      )!,
      yourSharePercent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}your_share_percent'],
      )!,
      method: $SplitsTable.$convertermethod.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}method'],
        )!,
      ),
      lastSettled: $SplitsTable.$converterlastSettledn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}last_settled'],
        ),
      ),
    );
  }

  @override
  $SplitsTable createAlias(String alias) {
    return $SplitsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SplitMethod, String, String> $convertermethod =
      const EnumNameConverter<SplitMethod>(SplitMethod.values);
  static TypeConverter<LocalDate, String> $converterlastSettled =
      const LocalDateConverter();
  static TypeConverter<LocalDate?, String?> $converterlastSettledn =
      NullAwareTypeConverter.wrap($converterlastSettled);
}

class SplitRow extends DataClass implements Insertable<SplitRow> {
  final String id;
  final String personName;
  final int yourSharePercent;
  final SplitMethod method;
  final LocalDate? lastSettled;
  const SplitRow({
    required this.id,
    required this.personName,
    required this.yourSharePercent,
    required this.method,
    this.lastSettled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['person_name'] = Variable<String>(personName);
    map['your_share_percent'] = Variable<int>(yourSharePercent);
    {
      map['method'] = Variable<String>(
        $SplitsTable.$convertermethod.toSql(method),
      );
    }
    if (!nullToAbsent || lastSettled != null) {
      map['last_settled'] = Variable<String>(
        $SplitsTable.$converterlastSettledn.toSql(lastSettled),
      );
    }
    return map;
  }

  SplitsCompanion toCompanion(bool nullToAbsent) {
    return SplitsCompanion(
      id: Value(id),
      personName: Value(personName),
      yourSharePercent: Value(yourSharePercent),
      method: Value(method),
      lastSettled: lastSettled == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSettled),
    );
  }

  factory SplitRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SplitRow(
      id: serializer.fromJson<String>(json['id']),
      personName: serializer.fromJson<String>(json['personName']),
      yourSharePercent: serializer.fromJson<int>(json['yourSharePercent']),
      method: $SplitsTable.$convertermethod.fromJson(
        serializer.fromJson<String>(json['method']),
      ),
      lastSettled: serializer.fromJson<LocalDate?>(json['lastSettled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'personName': serializer.toJson<String>(personName),
      'yourSharePercent': serializer.toJson<int>(yourSharePercent),
      'method': serializer.toJson<String>(
        $SplitsTable.$convertermethod.toJson(method),
      ),
      'lastSettled': serializer.toJson<LocalDate?>(lastSettled),
    };
  }

  SplitRow copyWith({
    String? id,
    String? personName,
    int? yourSharePercent,
    SplitMethod? method,
    Value<LocalDate?> lastSettled = const Value.absent(),
  }) => SplitRow(
    id: id ?? this.id,
    personName: personName ?? this.personName,
    yourSharePercent: yourSharePercent ?? this.yourSharePercent,
    method: method ?? this.method,
    lastSettled: lastSettled.present ? lastSettled.value : this.lastSettled,
  );
  SplitRow copyWithCompanion(SplitsCompanion data) {
    return SplitRow(
      id: data.id.present ? data.id.value : this.id,
      personName: data.personName.present
          ? data.personName.value
          : this.personName,
      yourSharePercent: data.yourSharePercent.present
          ? data.yourSharePercent.value
          : this.yourSharePercent,
      method: data.method.present ? data.method.value : this.method,
      lastSettled: data.lastSettled.present
          ? data.lastSettled.value
          : this.lastSettled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SplitRow(')
          ..write('id: $id, ')
          ..write('personName: $personName, ')
          ..write('yourSharePercent: $yourSharePercent, ')
          ..write('method: $method, ')
          ..write('lastSettled: $lastSettled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, personName, yourSharePercent, method, lastSettled);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SplitRow &&
          other.id == this.id &&
          other.personName == this.personName &&
          other.yourSharePercent == this.yourSharePercent &&
          other.method == this.method &&
          other.lastSettled == this.lastSettled);
}

class SplitsCompanion extends UpdateCompanion<SplitRow> {
  final Value<String> id;
  final Value<String> personName;
  final Value<int> yourSharePercent;
  final Value<SplitMethod> method;
  final Value<LocalDate?> lastSettled;
  final Value<int> rowid;
  const SplitsCompanion({
    this.id = const Value.absent(),
    this.personName = const Value.absent(),
    this.yourSharePercent = const Value.absent(),
    this.method = const Value.absent(),
    this.lastSettled = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SplitsCompanion.insert({
    required String id,
    required String personName,
    required int yourSharePercent,
    required SplitMethod method,
    this.lastSettled = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       personName = Value(personName),
       yourSharePercent = Value(yourSharePercent),
       method = Value(method);
  static Insertable<SplitRow> custom({
    Expression<String>? id,
    Expression<String>? personName,
    Expression<int>? yourSharePercent,
    Expression<String>? method,
    Expression<String>? lastSettled,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (personName != null) 'person_name': personName,
      if (yourSharePercent != null) 'your_share_percent': yourSharePercent,
      if (method != null) 'method': method,
      if (lastSettled != null) 'last_settled': lastSettled,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SplitsCompanion copyWith({
    Value<String>? id,
    Value<String>? personName,
    Value<int>? yourSharePercent,
    Value<SplitMethod>? method,
    Value<LocalDate?>? lastSettled,
    Value<int>? rowid,
  }) {
    return SplitsCompanion(
      id: id ?? this.id,
      personName: personName ?? this.personName,
      yourSharePercent: yourSharePercent ?? this.yourSharePercent,
      method: method ?? this.method,
      lastSettled: lastSettled ?? this.lastSettled,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (personName.present) {
      map['person_name'] = Variable<String>(personName.value);
    }
    if (yourSharePercent.present) {
      map['your_share_percent'] = Variable<int>(yourSharePercent.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(
        $SplitsTable.$convertermethod.toSql(method.value),
      );
    }
    if (lastSettled.present) {
      map['last_settled'] = Variable<String>(
        $SplitsTable.$converterlastSettledn.toSql(lastSettled.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SplitsCompanion(')
          ..write('id: $id, ')
          ..write('personName: $personName, ')
          ..write('yourSharePercent: $yourSharePercent, ')
          ..write('method: $method, ')
          ..write('lastSettled: $lastSettled, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SharedExpensesTable extends SharedExpenses
    with TableInfo<$SharedExpensesTable, SharedExpenseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SharedExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountCentsMeta = const VerificationMeta(
    'amountCents',
  );
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
    'amount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<LocalDate, String> date =
      GeneratedColumn<String>(
        'date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LocalDate>($SharedExpensesTable.$converterdate);
  static const VerificationMeta _paidByYouMeta = const VerificationMeta(
    'paidByYou',
  );
  @override
  late final GeneratedColumn<bool> paidByYou = GeneratedColumn<bool>(
    'paid_by_you',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("paid_by_you" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    amountCents,
    date,
    paidByYou,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shared_expenses';
  @override
  VerificationContext validateIntegrity(
    Insertable<SharedExpenseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
        _amountCentsMeta,
        amountCents.isAcceptableOrUnknown(
          data['amount_cents']!,
          _amountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountCentsMeta);
    }
    if (data.containsKey('paid_by_you')) {
      context.handle(
        _paidByYouMeta,
        paidByYou.isAcceptableOrUnknown(data['paid_by_you']!, _paidByYouMeta),
      );
    } else if (isInserting) {
      context.missing(_paidByYouMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SharedExpenseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SharedExpenseRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      amountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_cents'],
      )!,
      date: $SharedExpensesTable.$converterdate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}date'],
        )!,
      ),
      paidByYou: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}paid_by_you'],
      )!,
    );
  }

  @override
  $SharedExpensesTable createAlias(String alias) {
    return $SharedExpensesTable(attachedDatabase, alias);
  }

  static TypeConverter<LocalDate, String> $converterdate =
      const LocalDateConverter();
}

class SharedExpenseRow extends DataClass
    implements Insertable<SharedExpenseRow> {
  final String id;
  final String name;
  final int amountCents;
  final LocalDate date;
  final bool paidByYou;
  const SharedExpenseRow({
    required this.id,
    required this.name,
    required this.amountCents,
    required this.date,
    required this.paidByYou,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['amount_cents'] = Variable<int>(amountCents);
    {
      map['date'] = Variable<String>(
        $SharedExpensesTable.$converterdate.toSql(date),
      );
    }
    map['paid_by_you'] = Variable<bool>(paidByYou);
    return map;
  }

  SharedExpensesCompanion toCompanion(bool nullToAbsent) {
    return SharedExpensesCompanion(
      id: Value(id),
      name: Value(name),
      amountCents: Value(amountCents),
      date: Value(date),
      paidByYou: Value(paidByYou),
    );
  }

  factory SharedExpenseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SharedExpenseRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      amountCents: serializer.fromJson<int>(json['amountCents']),
      date: serializer.fromJson<LocalDate>(json['date']),
      paidByYou: serializer.fromJson<bool>(json['paidByYou']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'amountCents': serializer.toJson<int>(amountCents),
      'date': serializer.toJson<LocalDate>(date),
      'paidByYou': serializer.toJson<bool>(paidByYou),
    };
  }

  SharedExpenseRow copyWith({
    String? id,
    String? name,
    int? amountCents,
    LocalDate? date,
    bool? paidByYou,
  }) => SharedExpenseRow(
    id: id ?? this.id,
    name: name ?? this.name,
    amountCents: amountCents ?? this.amountCents,
    date: date ?? this.date,
    paidByYou: paidByYou ?? this.paidByYou,
  );
  SharedExpenseRow copyWithCompanion(SharedExpensesCompanion data) {
    return SharedExpenseRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      amountCents: data.amountCents.present
          ? data.amountCents.value
          : this.amountCents,
      date: data.date.present ? data.date.value : this.date,
      paidByYou: data.paidByYou.present ? data.paidByYou.value : this.paidByYou,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SharedExpenseRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('amountCents: $amountCents, ')
          ..write('date: $date, ')
          ..write('paidByYou: $paidByYou')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, amountCents, date, paidByYou);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SharedExpenseRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.amountCents == this.amountCents &&
          other.date == this.date &&
          other.paidByYou == this.paidByYou);
}

class SharedExpensesCompanion extends UpdateCompanion<SharedExpenseRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> amountCents;
  final Value<LocalDate> date;
  final Value<bool> paidByYou;
  final Value<int> rowid;
  const SharedExpensesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.date = const Value.absent(),
    this.paidByYou = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SharedExpensesCompanion.insert({
    required String id,
    required String name,
    required int amountCents,
    required LocalDate date,
    required bool paidByYou,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       amountCents = Value(amountCents),
       date = Value(date),
       paidByYou = Value(paidByYou);
  static Insertable<SharedExpenseRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? amountCents,
    Expression<String>? date,
    Expression<bool>? paidByYou,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (amountCents != null) 'amount_cents': amountCents,
      if (date != null) 'date': date,
      if (paidByYou != null) 'paid_by_you': paidByYou,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SharedExpensesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? amountCents,
    Value<LocalDate>? date,
    Value<bool>? paidByYou,
    Value<int>? rowid,
  }) {
    return SharedExpensesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      amountCents: amountCents ?? this.amountCents,
      date: date ?? this.date,
      paidByYou: paidByYou ?? this.paidByYou,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(
        $SharedExpensesTable.$converterdate.toSql(date.value),
      );
    }
    if (paidByYou.present) {
      map['paid_by_you'] = Variable<bool>(paidByYou.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SharedExpensesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('amountCents: $amountCents, ')
          ..write('date: $date, ')
          ..write('paidByYou: $paidByYou, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OverspendDecisionsTable extends OverspendDecisions
    with TableInfo<$OverspendDecisionsTable, OverspendDecisionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OverspendDecisionsTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<LocalDate, String> localDate =
      GeneratedColumn<String>(
        'local_date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LocalDate>($OverspendDecisionsTable.$converterlocalDate);
  @override
  late final GeneratedColumnWithTypeConverter<OverspendStrategy, String>
  strategy =
      GeneratedColumn<String>(
        'strategy',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<OverspendStrategy>(
        $OverspendDecisionsTable.$converterstrategy,
      );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountCentsMeta = const VerificationMeta(
    'amountCents',
  );
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
    'amount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    localDate,
    strategy,
    categoryId,
    amountCents,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'overspend_decisions';
  @override
  VerificationContext validateIntegrity(
    Insertable<OverspendDecisionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
        _amountCentsMeta,
        amountCents.isAcceptableOrUnknown(
          data['amount_cents']!,
          _amountCentsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localDate};
  @override
  OverspendDecisionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OverspendDecisionRow(
      localDate: $OverspendDecisionsTable.$converterlocalDate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}local_date'],
        )!,
      ),
      strategy: $OverspendDecisionsTable.$converterstrategy.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}strategy'],
        )!,
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      amountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_cents'],
      )!,
    );
  }

  @override
  $OverspendDecisionsTable createAlias(String alias) {
    return $OverspendDecisionsTable(attachedDatabase, alias);
  }

  static TypeConverter<LocalDate, String> $converterlocalDate =
      const LocalDateConverter();
  static JsonTypeConverter2<OverspendStrategy, String, String>
  $converterstrategy = const EnumNameConverter<OverspendStrategy>(
    OverspendStrategy.values,
  );
}

class OverspendDecisionRow extends DataClass
    implements Insertable<OverspendDecisionRow> {
  final LocalDate localDate;
  final OverspendStrategy strategy;

  /// v6: "Take it from Fun money" — which category covered how much.
  final String? categoryId;
  final int amountCents;
  const OverspendDecisionRow({
    required this.localDate,
    required this.strategy,
    this.categoryId,
    required this.amountCents,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['local_date'] = Variable<String>(
        $OverspendDecisionsTable.$converterlocalDate.toSql(localDate),
      );
    }
    {
      map['strategy'] = Variable<String>(
        $OverspendDecisionsTable.$converterstrategy.toSql(strategy),
      );
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    map['amount_cents'] = Variable<int>(amountCents);
    return map;
  }

  OverspendDecisionsCompanion toCompanion(bool nullToAbsent) {
    return OverspendDecisionsCompanion(
      localDate: Value(localDate),
      strategy: Value(strategy),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      amountCents: Value(amountCents),
    );
  }

  factory OverspendDecisionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OverspendDecisionRow(
      localDate: serializer.fromJson<LocalDate>(json['localDate']),
      strategy: $OverspendDecisionsTable.$converterstrategy.fromJson(
        serializer.fromJson<String>(json['strategy']),
      ),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      amountCents: serializer.fromJson<int>(json['amountCents']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localDate': serializer.toJson<LocalDate>(localDate),
      'strategy': serializer.toJson<String>(
        $OverspendDecisionsTable.$converterstrategy.toJson(strategy),
      ),
      'categoryId': serializer.toJson<String?>(categoryId),
      'amountCents': serializer.toJson<int>(amountCents),
    };
  }

  OverspendDecisionRow copyWith({
    LocalDate? localDate,
    OverspendStrategy? strategy,
    Value<String?> categoryId = const Value.absent(),
    int? amountCents,
  }) => OverspendDecisionRow(
    localDate: localDate ?? this.localDate,
    strategy: strategy ?? this.strategy,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    amountCents: amountCents ?? this.amountCents,
  );
  OverspendDecisionRow copyWithCompanion(OverspendDecisionsCompanion data) {
    return OverspendDecisionRow(
      localDate: data.localDate.present ? data.localDate.value : this.localDate,
      strategy: data.strategy.present ? data.strategy.value : this.strategy,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      amountCents: data.amountCents.present
          ? data.amountCents.value
          : this.amountCents,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OverspendDecisionRow(')
          ..write('localDate: $localDate, ')
          ..write('strategy: $strategy, ')
          ..write('categoryId: $categoryId, ')
          ..write('amountCents: $amountCents')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(localDate, strategy, categoryId, amountCents);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OverspendDecisionRow &&
          other.localDate == this.localDate &&
          other.strategy == this.strategy &&
          other.categoryId == this.categoryId &&
          other.amountCents == this.amountCents);
}

class OverspendDecisionsCompanion
    extends UpdateCompanion<OverspendDecisionRow> {
  final Value<LocalDate> localDate;
  final Value<OverspendStrategy> strategy;
  final Value<String?> categoryId;
  final Value<int> amountCents;
  final Value<int> rowid;
  const OverspendDecisionsCompanion({
    this.localDate = const Value.absent(),
    this.strategy = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OverspendDecisionsCompanion.insert({
    required LocalDate localDate,
    required OverspendStrategy strategy,
    this.categoryId = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : localDate = Value(localDate),
       strategy = Value(strategy);
  static Insertable<OverspendDecisionRow> custom({
    Expression<String>? localDate,
    Expression<String>? strategy,
    Expression<String>? categoryId,
    Expression<int>? amountCents,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localDate != null) 'local_date': localDate,
      if (strategy != null) 'strategy': strategy,
      if (categoryId != null) 'category_id': categoryId,
      if (amountCents != null) 'amount_cents': amountCents,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OverspendDecisionsCompanion copyWith({
    Value<LocalDate>? localDate,
    Value<OverspendStrategy>? strategy,
    Value<String?>? categoryId,
    Value<int>? amountCents,
    Value<int>? rowid,
  }) {
    return OverspendDecisionsCompanion(
      localDate: localDate ?? this.localDate,
      strategy: strategy ?? this.strategy,
      categoryId: categoryId ?? this.categoryId,
      amountCents: amountCents ?? this.amountCents,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localDate.present) {
      map['local_date'] = Variable<String>(
        $OverspendDecisionsTable.$converterlocalDate.toSql(localDate.value),
      );
    }
    if (strategy.present) {
      map['strategy'] = Variable<String>(
        $OverspendDecisionsTable.$converterstrategy.toSql(strategy.value),
      );
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OverspendDecisionsCompanion(')
          ..write('localDate: $localDate, ')
          ..write('strategy: $strategy, ')
          ..write('categoryId: $categoryId, ')
          ..write('amountCents: $amountCents, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyNumbersTable extends DailyNumbers
    with TableInfo<$DailyNumbersTable, DailyNumberRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyNumbersTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<LocalDate, String> localDate =
      GeneratedColumn<String>(
        'local_date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LocalDate>($DailyNumbersTable.$converterlocalDate);
  static const VerificationMeta _allowanceCentsMeta = const VerificationMeta(
    'allowanceCents',
  );
  @override
  late final GeneratedColumn<int> allowanceCents = GeneratedColumn<int>(
    'allowance_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [localDate, allowanceCents];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_numbers';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyNumberRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('allowance_cents')) {
      context.handle(
        _allowanceCentsMeta,
        allowanceCents.isAcceptableOrUnknown(
          data['allowance_cents']!,
          _allowanceCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_allowanceCentsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localDate};
  @override
  DailyNumberRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyNumberRow(
      localDate: $DailyNumbersTable.$converterlocalDate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}local_date'],
        )!,
      ),
      allowanceCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}allowance_cents'],
      )!,
    );
  }

  @override
  $DailyNumbersTable createAlias(String alias) {
    return $DailyNumbersTable(attachedDatabase, alias);
  }

  static TypeConverter<LocalDate, String> $converterlocalDate =
      const LocalDateConverter();
}

class DailyNumberRow extends DataClass implements Insertable<DailyNumberRow> {
  final LocalDate localDate;
  final int allowanceCents;
  const DailyNumberRow({required this.localDate, required this.allowanceCents});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['local_date'] = Variable<String>(
        $DailyNumbersTable.$converterlocalDate.toSql(localDate),
      );
    }
    map['allowance_cents'] = Variable<int>(allowanceCents);
    return map;
  }

  DailyNumbersCompanion toCompanion(bool nullToAbsent) {
    return DailyNumbersCompanion(
      localDate: Value(localDate),
      allowanceCents: Value(allowanceCents),
    );
  }

  factory DailyNumberRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyNumberRow(
      localDate: serializer.fromJson<LocalDate>(json['localDate']),
      allowanceCents: serializer.fromJson<int>(json['allowanceCents']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localDate': serializer.toJson<LocalDate>(localDate),
      'allowanceCents': serializer.toJson<int>(allowanceCents),
    };
  }

  DailyNumberRow copyWith({LocalDate? localDate, int? allowanceCents}) =>
      DailyNumberRow(
        localDate: localDate ?? this.localDate,
        allowanceCents: allowanceCents ?? this.allowanceCents,
      );
  DailyNumberRow copyWithCompanion(DailyNumbersCompanion data) {
    return DailyNumberRow(
      localDate: data.localDate.present ? data.localDate.value : this.localDate,
      allowanceCents: data.allowanceCents.present
          ? data.allowanceCents.value
          : this.allowanceCents,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyNumberRow(')
          ..write('localDate: $localDate, ')
          ..write('allowanceCents: $allowanceCents')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(localDate, allowanceCents);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyNumberRow &&
          other.localDate == this.localDate &&
          other.allowanceCents == this.allowanceCents);
}

class DailyNumbersCompanion extends UpdateCompanion<DailyNumberRow> {
  final Value<LocalDate> localDate;
  final Value<int> allowanceCents;
  final Value<int> rowid;
  const DailyNumbersCompanion({
    this.localDate = const Value.absent(),
    this.allowanceCents = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyNumbersCompanion.insert({
    required LocalDate localDate,
    required int allowanceCents,
    this.rowid = const Value.absent(),
  }) : localDate = Value(localDate),
       allowanceCents = Value(allowanceCents);
  static Insertable<DailyNumberRow> custom({
    Expression<String>? localDate,
    Expression<int>? allowanceCents,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localDate != null) 'local_date': localDate,
      if (allowanceCents != null) 'allowance_cents': allowanceCents,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyNumbersCompanion copyWith({
    Value<LocalDate>? localDate,
    Value<int>? allowanceCents,
    Value<int>? rowid,
  }) {
    return DailyNumbersCompanion(
      localDate: localDate ?? this.localDate,
      allowanceCents: allowanceCents ?? this.allowanceCents,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localDate.present) {
      map['local_date'] = Variable<String>(
        $DailyNumbersTable.$converterlocalDate.toSql(localDate.value),
      );
    }
    if (allowanceCents.present) {
      map['allowance_cents'] = Variable<int>(allowanceCents.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyNumbersCompanion(')
          ..write('localDate: $localDate, ')
          ..write('allowanceCents: $allowanceCents, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$SteadyDatabase extends GeneratedDatabase {
  _$SteadyDatabase(QueryExecutor e) : super(e);
  $SteadyDatabaseManager get managers => $SteadyDatabaseManager(this);
  late final $SettingsRowsTable settingsRows = $SettingsRowsTable(this);
  late final $CyclePlansTable cyclePlans = $CyclePlansTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $EntriesTable entries = $EntriesTable(this);
  late final $BillsTable bills = $BillsTable(this);
  late final $GoalsTable goals = $GoalsTable(this);
  late final $VaultsTable vaults = $VaultsTable(this);
  late final $SplitsTable splits = $SplitsTable(this);
  late final $SharedExpensesTable sharedExpenses = $SharedExpensesTable(this);
  late final $OverspendDecisionsTable overspendDecisions =
      $OverspendDecisionsTable(this);
  late final $DailyNumbersTable dailyNumbers = $DailyNumbersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    settingsRows,
    cyclePlans,
    categories,
    entries,
    bills,
    goals,
    vaults,
    splits,
    sharedExpenses,
    overspendDecisions,
    dailyNumbers,
  ];
}

typedef $$SettingsRowsTableCreateCompanionBuilder =
    SettingsRowsCompanion Function({
      Value<int> id,
      required Currency currency,
      required PayFrequency payFrequency,
      required LocalDate nextPayday,
      required IncomeType incomeType,
      Value<String?> displayName,
      Value<int?> hourlyRateCents,
      Value<int> weekStartsOn,
      required ThemePreference theme,
      Value<bool> appLockEnabled,
      required OverspendStrategy overspendStrategy,
      Value<bool> onboarded,
      Value<LocalDate?> lastBackupOn,
      Value<bool> remindLogSpends,
      Value<int> remindLogAt,
      Value<bool> remindBills,
      Value<bool> remindLatePause,
      Value<bool> remindRecaps,
      Value<bool> remindBackup,
      Value<int> quietFrom,
      Value<bool> biometricUnlock,
    });
typedef $$SettingsRowsTableUpdateCompanionBuilder =
    SettingsRowsCompanion Function({
      Value<int> id,
      Value<Currency> currency,
      Value<PayFrequency> payFrequency,
      Value<LocalDate> nextPayday,
      Value<IncomeType> incomeType,
      Value<String?> displayName,
      Value<int?> hourlyRateCents,
      Value<int> weekStartsOn,
      Value<ThemePreference> theme,
      Value<bool> appLockEnabled,
      Value<OverspendStrategy> overspendStrategy,
      Value<bool> onboarded,
      Value<LocalDate?> lastBackupOn,
      Value<bool> remindLogSpends,
      Value<int> remindLogAt,
      Value<bool> remindBills,
      Value<bool> remindLatePause,
      Value<bool> remindRecaps,
      Value<bool> remindBackup,
      Value<int> quietFrom,
      Value<bool> biometricUnlock,
    });

class $$SettingsRowsTableFilterComposer
    extends Composer<_$SteadyDatabase, $SettingsRowsTable> {
  $$SettingsRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Currency, Currency, String> get currency =>
      $composableBuilder(
        column: $table.currency,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<PayFrequency, PayFrequency, String>
  get payFrequency => $composableBuilder(
    column: $table.payFrequency,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<LocalDate, LocalDate, String> get nextPayday =>
      $composableBuilder(
        column: $table.nextPayday,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<IncomeType, IncomeType, String>
  get incomeType => $composableBuilder(
    column: $table.incomeType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hourlyRateCents => $composableBuilder(
    column: $table.hourlyRateCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekStartsOn => $composableBuilder(
    column: $table.weekStartsOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ThemePreference, ThemePreference, String>
  get theme => $composableBuilder(
    column: $table.theme,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get appLockEnabled => $composableBuilder(
    column: $table.appLockEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<OverspendStrategy, OverspendStrategy, String>
  get overspendStrategy => $composableBuilder(
    column: $table.overspendStrategy,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get onboarded => $composableBuilder(
    column: $table.onboarded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LocalDate?, LocalDate, String>
  get lastBackupOn => $composableBuilder(
    column: $table.lastBackupOn,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get remindLogSpends => $composableBuilder(
    column: $table.remindLogSpends,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remindLogAt => $composableBuilder(
    column: $table.remindLogAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get remindBills => $composableBuilder(
    column: $table.remindBills,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get remindLatePause => $composableBuilder(
    column: $table.remindLatePause,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get remindRecaps => $composableBuilder(
    column: $table.remindRecaps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get remindBackup => $composableBuilder(
    column: $table.remindBackup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quietFrom => $composableBuilder(
    column: $table.quietFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get biometricUnlock => $composableBuilder(
    column: $table.biometricUnlock,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsRowsTableOrderingComposer
    extends Composer<_$SteadyDatabase, $SettingsRowsTable> {
  $$SettingsRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payFrequency => $composableBuilder(
    column: $table.payFrequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nextPayday => $composableBuilder(
    column: $table.nextPayday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get incomeType => $composableBuilder(
    column: $table.incomeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hourlyRateCents => $composableBuilder(
    column: $table.hourlyRateCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekStartsOn => $composableBuilder(
    column: $table.weekStartsOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get theme => $composableBuilder(
    column: $table.theme,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get appLockEnabled => $composableBuilder(
    column: $table.appLockEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get overspendStrategy => $composableBuilder(
    column: $table.overspendStrategy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get onboarded => $composableBuilder(
    column: $table.onboarded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastBackupOn => $composableBuilder(
    column: $table.lastBackupOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get remindLogSpends => $composableBuilder(
    column: $table.remindLogSpends,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remindLogAt => $composableBuilder(
    column: $table.remindLogAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get remindBills => $composableBuilder(
    column: $table.remindBills,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get remindLatePause => $composableBuilder(
    column: $table.remindLatePause,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get remindRecaps => $composableBuilder(
    column: $table.remindRecaps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get remindBackup => $composableBuilder(
    column: $table.remindBackup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quietFrom => $composableBuilder(
    column: $table.quietFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get biometricUnlock => $composableBuilder(
    column: $table.biometricUnlock,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsRowsTableAnnotationComposer
    extends Composer<_$SteadyDatabase, $SettingsRowsTable> {
  $$SettingsRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Currency, String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PayFrequency, String> get payFrequency =>
      $composableBuilder(
        column: $table.payFrequency,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<LocalDate, String> get nextPayday =>
      $composableBuilder(
        column: $table.nextPayday,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<IncomeType, String> get incomeType =>
      $composableBuilder(
        column: $table.incomeType,
        builder: (column) => column,
      );

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get hourlyRateCents => $composableBuilder(
    column: $table.hourlyRateCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get weekStartsOn => $composableBuilder(
    column: $table.weekStartsOn,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ThemePreference, String> get theme =>
      $composableBuilder(column: $table.theme, builder: (column) => column);

  GeneratedColumn<bool> get appLockEnabled => $composableBuilder(
    column: $table.appLockEnabled,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<OverspendStrategy, String>
  get overspendStrategy => $composableBuilder(
    column: $table.overspendStrategy,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get onboarded =>
      $composableBuilder(column: $table.onboarded, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LocalDate?, String> get lastBackupOn =>
      $composableBuilder(
        column: $table.lastBackupOn,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get remindLogSpends => $composableBuilder(
    column: $table.remindLogSpends,
    builder: (column) => column,
  );

  GeneratedColumn<int> get remindLogAt => $composableBuilder(
    column: $table.remindLogAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get remindBills => $composableBuilder(
    column: $table.remindBills,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get remindLatePause => $composableBuilder(
    column: $table.remindLatePause,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get remindRecaps => $composableBuilder(
    column: $table.remindRecaps,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get remindBackup => $composableBuilder(
    column: $table.remindBackup,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quietFrom =>
      $composableBuilder(column: $table.quietFrom, builder: (column) => column);

  GeneratedColumn<bool> get biometricUnlock => $composableBuilder(
    column: $table.biometricUnlock,
    builder: (column) => column,
  );
}

class $$SettingsRowsTableTableManager
    extends
        RootTableManager<
          _$SteadyDatabase,
          $SettingsRowsTable,
          SettingsRow,
          $$SettingsRowsTableFilterComposer,
          $$SettingsRowsTableOrderingComposer,
          $$SettingsRowsTableAnnotationComposer,
          $$SettingsRowsTableCreateCompanionBuilder,
          $$SettingsRowsTableUpdateCompanionBuilder,
          (
            SettingsRow,
            BaseReferences<_$SteadyDatabase, $SettingsRowsTable, SettingsRow>,
          ),
          SettingsRow,
          PrefetchHooks Function()
        > {
  $$SettingsRowsTableTableManager(_$SteadyDatabase db, $SettingsRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<Currency> currency = const Value.absent(),
                Value<PayFrequency> payFrequency = const Value.absent(),
                Value<LocalDate> nextPayday = const Value.absent(),
                Value<IncomeType> incomeType = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<int?> hourlyRateCents = const Value.absent(),
                Value<int> weekStartsOn = const Value.absent(),
                Value<ThemePreference> theme = const Value.absent(),
                Value<bool> appLockEnabled = const Value.absent(),
                Value<OverspendStrategy> overspendStrategy =
                    const Value.absent(),
                Value<bool> onboarded = const Value.absent(),
                Value<LocalDate?> lastBackupOn = const Value.absent(),
                Value<bool> remindLogSpends = const Value.absent(),
                Value<int> remindLogAt = const Value.absent(),
                Value<bool> remindBills = const Value.absent(),
                Value<bool> remindLatePause = const Value.absent(),
                Value<bool> remindRecaps = const Value.absent(),
                Value<bool> remindBackup = const Value.absent(),
                Value<int> quietFrom = const Value.absent(),
                Value<bool> biometricUnlock = const Value.absent(),
              }) => SettingsRowsCompanion(
                id: id,
                currency: currency,
                payFrequency: payFrequency,
                nextPayday: nextPayday,
                incomeType: incomeType,
                displayName: displayName,
                hourlyRateCents: hourlyRateCents,
                weekStartsOn: weekStartsOn,
                theme: theme,
                appLockEnabled: appLockEnabled,
                overspendStrategy: overspendStrategy,
                onboarded: onboarded,
                lastBackupOn: lastBackupOn,
                remindLogSpends: remindLogSpends,
                remindLogAt: remindLogAt,
                remindBills: remindBills,
                remindLatePause: remindLatePause,
                remindRecaps: remindRecaps,
                remindBackup: remindBackup,
                quietFrom: quietFrom,
                biometricUnlock: biometricUnlock,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required Currency currency,
                required PayFrequency payFrequency,
                required LocalDate nextPayday,
                required IncomeType incomeType,
                Value<String?> displayName = const Value.absent(),
                Value<int?> hourlyRateCents = const Value.absent(),
                Value<int> weekStartsOn = const Value.absent(),
                required ThemePreference theme,
                Value<bool> appLockEnabled = const Value.absent(),
                required OverspendStrategy overspendStrategy,
                Value<bool> onboarded = const Value.absent(),
                Value<LocalDate?> lastBackupOn = const Value.absent(),
                Value<bool> remindLogSpends = const Value.absent(),
                Value<int> remindLogAt = const Value.absent(),
                Value<bool> remindBills = const Value.absent(),
                Value<bool> remindLatePause = const Value.absent(),
                Value<bool> remindRecaps = const Value.absent(),
                Value<bool> remindBackup = const Value.absent(),
                Value<int> quietFrom = const Value.absent(),
                Value<bool> biometricUnlock = const Value.absent(),
              }) => SettingsRowsCompanion.insert(
                id: id,
                currency: currency,
                payFrequency: payFrequency,
                nextPayday: nextPayday,
                incomeType: incomeType,
                displayName: displayName,
                hourlyRateCents: hourlyRateCents,
                weekStartsOn: weekStartsOn,
                theme: theme,
                appLockEnabled: appLockEnabled,
                overspendStrategy: overspendStrategy,
                onboarded: onboarded,
                lastBackupOn: lastBackupOn,
                remindLogSpends: remindLogSpends,
                remindLogAt: remindLogAt,
                remindBills: remindBills,
                remindLatePause: remindLatePause,
                remindRecaps: remindRecaps,
                remindBackup: remindBackup,
                quietFrom: quietFrom,
                biometricUnlock: biometricUnlock,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsRowsTable, SettingsRow>(table),
                  BaseReferences<
                    _$SteadyDatabase,
                    $SettingsRowsTable,
                    SettingsRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$SteadyDatabase,
      $SettingsRowsTable,
      SettingsRow,
      $$SettingsRowsTableFilterComposer,
      $$SettingsRowsTableOrderingComposer,
      $$SettingsRowsTableAnnotationComposer,
      $$SettingsRowsTableCreateCompanionBuilder,
      $$SettingsRowsTableUpdateCompanionBuilder,
      (
        SettingsRow,
        BaseReferences<_$SteadyDatabase, $SettingsRowsTable, SettingsRow>,
      ),
      SettingsRow,
      PrefetchHooks Function()
    >;
typedef $$CyclePlansTableCreateCompanionBuilder = CyclePlansCompanion Function({
  Value<int> id,
  required LocalDate startDate,
  required int openingBalanceCents,
  required int goalSetAsideCents,
});
typedef $$CyclePlansTableUpdateCompanionBuilder = CyclePlansCompanion Function({
  Value<int> id,
  Value<LocalDate> startDate,
  Value<int> openingBalanceCents,
  Value<int> goalSetAsideCents,
});

class $$CyclePlansTableFilterComposer
    extends Composer<_$SteadyDatabase, $CyclePlansTable> {
  $$CyclePlansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LocalDate, LocalDate, String> get startDate =>
      $composableBuilder(
        column: $table.startDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get openingBalanceCents => $composableBuilder(
    column: $table.openingBalanceCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get goalSetAsideCents => $composableBuilder(
    column: $table.goalSetAsideCents,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CyclePlansTableOrderingComposer
    extends Composer<_$SteadyDatabase, $CyclePlansTable> {
  $$CyclePlansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get openingBalanceCents => $composableBuilder(
    column: $table.openingBalanceCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get goalSetAsideCents => $composableBuilder(
    column: $table.goalSetAsideCents,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CyclePlansTableAnnotationComposer
    extends Composer<_$SteadyDatabase, $CyclePlansTable> {
  $$CyclePlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LocalDate, String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<int> get openingBalanceCents => $composableBuilder(
    column: $table.openingBalanceCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get goalSetAsideCents => $composableBuilder(
    column: $table.goalSetAsideCents,
    builder: (column) => column,
  );
}

class $$CyclePlansTableTableManager
    extends
        RootTableManager<
          _$SteadyDatabase,
          $CyclePlansTable,
          CyclePlanRow,
          $$CyclePlansTableFilterComposer,
          $$CyclePlansTableOrderingComposer,
          $$CyclePlansTableAnnotationComposer,
          $$CyclePlansTableCreateCompanionBuilder,
          $$CyclePlansTableUpdateCompanionBuilder,
          (
            CyclePlanRow,
            BaseReferences<_$SteadyDatabase, $CyclePlansTable, CyclePlanRow>,
          ),
          CyclePlanRow,
          PrefetchHooks Function()
        > {
  $$CyclePlansTableTableManager(_$SteadyDatabase db, $CyclePlansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CyclePlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CyclePlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CyclePlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<LocalDate> startDate = const Value.absent(),
                Value<int> openingBalanceCents = const Value.absent(),
                Value<int> goalSetAsideCents = const Value.absent(),
              }) => CyclePlansCompanion(
                id: id,
                startDate: startDate,
                openingBalanceCents: openingBalanceCents,
                goalSetAsideCents: goalSetAsideCents,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required LocalDate startDate,
                required int openingBalanceCents,
                required int goalSetAsideCents,
              }) => CyclePlansCompanion.insert(
                id: id,
                startDate: startDate,
                openingBalanceCents: openingBalanceCents,
                goalSetAsideCents: goalSetAsideCents,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CyclePlansTable, CyclePlanRow>(table),
                  BaseReferences<
                    _$SteadyDatabase,
                    $CyclePlansTable,
                    CyclePlanRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CyclePlansTableProcessedTableManager =
    ProcessedTableManager<
      _$SteadyDatabase,
      $CyclePlansTable,
      CyclePlanRow,
      $$CyclePlansTableFilterComposer,
      $$CyclePlansTableOrderingComposer,
      $$CyclePlansTableAnnotationComposer,
      $$CyclePlansTableCreateCompanionBuilder,
      $$CyclePlansTableUpdateCompanionBuilder,
      (
        CyclePlanRow,
        BaseReferences<_$SteadyDatabase, $CyclePlansTable, CyclePlanRow>,
      ),
      CyclePlanRow,
      PrefetchHooks Function()
    >;
typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  required String id,
  required String name,
  required CategoryTone tone,
  Value<int?> monthlyLimitCents,
  Value<int> sortOrder,
  Value<int> rowid,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<CategoryTone> tone,
  Value<int?> monthlyLimitCents,
  Value<int> sortOrder,
  Value<int> rowid,
});

class $$CategoriesTableFilterComposer
    extends Composer<_$SteadyDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CategoryTone, CategoryTone, String> get tone =>
      $composableBuilder(
        column: $table.tone,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get monthlyLimitCents => $composableBuilder(
    column: $table.monthlyLimitCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$SteadyDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tone => $composableBuilder(
    column: $table.tone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monthlyLimitCents => $composableBuilder(
    column: $table.monthlyLimitCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$SteadyDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CategoryTone, String> get tone =>
      $composableBuilder(column: $table.tone, builder: (column) => column);

  GeneratedColumn<int> get monthlyLimitCents => $composableBuilder(
    column: $table.monthlyLimitCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$SteadyDatabase,
          $CategoriesTable,
          CategoryRow,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (
            CategoryRow,
            BaseReferences<_$SteadyDatabase, $CategoriesTable, CategoryRow>,
          ),
          CategoryRow,
          PrefetchHooks Function()
        > {
  $$CategoriesTableTableManager(_$SteadyDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<CategoryTone> tone = const Value.absent(),
                Value<int?> monthlyLimitCents = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                tone: tone,
                monthlyLimitCents: monthlyLimitCents,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required CategoryTone tone,
                Value<int?> monthlyLimitCents = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                tone: tone,
                monthlyLimitCents: monthlyLimitCents,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CategoriesTable, CategoryRow>(table),
                  BaseReferences<
                    _$SteadyDatabase,
                    $CategoriesTable,
                    CategoryRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$SteadyDatabase,
      $CategoriesTable,
      CategoryRow,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (
        CategoryRow,
        BaseReferences<_$SteadyDatabase, $CategoriesTable, CategoryRow>,
      ),
      CategoryRow,
      PrefetchHooks Function()
    >;
typedef $$EntriesTableCreateCompanionBuilder = EntriesCompanion Function({
  required String id,
  required EntryType type,
  required int amountCents,
  required LocalDate localDate,
  required DateTime createdAtUtc,
  required String timeZoneId,
  Value<String?> merchant,
  Value<String?> categoryId,
  Value<Mood?> mood,
  Value<bool?> planned,
  Value<String?> note,
  Value<String?> splitId,
  Value<bool> toVault,
  Value<bool> fromVault,
  Value<String?> billId,
  Value<int> rowid,
});
typedef $$EntriesTableUpdateCompanionBuilder = EntriesCompanion Function({
  Value<String> id,
  Value<EntryType> type,
  Value<int> amountCents,
  Value<LocalDate> localDate,
  Value<DateTime> createdAtUtc,
  Value<String> timeZoneId,
  Value<String?> merchant,
  Value<String?> categoryId,
  Value<Mood?> mood,
  Value<bool?> planned,
  Value<String?> note,
  Value<String?> splitId,
  Value<bool> toVault,
  Value<bool> fromVault,
  Value<String?> billId,
  Value<int> rowid,
});

class $$EntriesTableFilterComposer
    extends Composer<_$SteadyDatabase, $EntriesTable> {
  $$EntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<EntryType, EntryType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LocalDate, LocalDate, String> get localDate =>
      $composableBuilder(
        column: $table.localDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeZoneId => $composableBuilder(
    column: $table.timeZoneId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Mood?, Mood, String> get mood =>
      $composableBuilder(
        column: $table.mood,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get planned => $composableBuilder(
    column: $table.planned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get splitId => $composableBuilder(
    column: $table.splitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get toVault => $composableBuilder(
    column: $table.toVault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get fromVault => $composableBuilder(
    column: $table.fromVault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get billId => $composableBuilder(
    column: $table.billId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EntriesTableOrderingComposer
    extends Composer<_$SteadyDatabase, $EntriesTable> {
  $$EntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeZoneId => $composableBuilder(
    column: $table.timeZoneId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get planned => $composableBuilder(
    column: $table.planned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get splitId => $composableBuilder(
    column: $table.splitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get toVault => $composableBuilder(
    column: $table.toVault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get fromVault => $composableBuilder(
    column: $table.fromVault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get billId => $composableBuilder(
    column: $table.billId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EntriesTableAnnotationComposer
    extends Composer<_$SteadyDatabase, $EntriesTable> {
  $$EntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<EntryType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<LocalDate, String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get timeZoneId => $composableBuilder(
    column: $table.timeZoneId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get merchant =>
      $composableBuilder(column: $table.merchant, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Mood?, String> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => column);

  GeneratedColumn<bool> get planned =>
      $composableBuilder(column: $table.planned, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get splitId =>
      $composableBuilder(column: $table.splitId, builder: (column) => column);

  GeneratedColumn<bool> get toVault =>
      $composableBuilder(column: $table.toVault, builder: (column) => column);

  GeneratedColumn<bool> get fromVault =>
      $composableBuilder(column: $table.fromVault, builder: (column) => column);

  GeneratedColumn<String> get billId =>
      $composableBuilder(column: $table.billId, builder: (column) => column);
}

class $$EntriesTableTableManager
    extends
        RootTableManager<
          _$SteadyDatabase,
          $EntriesTable,
          EntryRow,
          $$EntriesTableFilterComposer,
          $$EntriesTableOrderingComposer,
          $$EntriesTableAnnotationComposer,
          $$EntriesTableCreateCompanionBuilder,
          $$EntriesTableUpdateCompanionBuilder,
          (EntryRow, BaseReferences<_$SteadyDatabase, $EntriesTable, EntryRow>),
          EntryRow,
          PrefetchHooks Function()
        > {
  $$EntriesTableTableManager(_$SteadyDatabase db, $EntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<EntryType> type = const Value.absent(),
                Value<int> amountCents = const Value.absent(),
                Value<LocalDate> localDate = const Value.absent(),
                Value<DateTime> createdAtUtc = const Value.absent(),
                Value<String> timeZoneId = const Value.absent(),
                Value<String?> merchant = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<Mood?> mood = const Value.absent(),
                Value<bool?> planned = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> splitId = const Value.absent(),
                Value<bool> toVault = const Value.absent(),
                Value<bool> fromVault = const Value.absent(),
                Value<String?> billId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntriesCompanion(
                id: id,
                type: type,
                amountCents: amountCents,
                localDate: localDate,
                createdAtUtc: createdAtUtc,
                timeZoneId: timeZoneId,
                merchant: merchant,
                categoryId: categoryId,
                mood: mood,
                planned: planned,
                note: note,
                splitId: splitId,
                toVault: toVault,
                fromVault: fromVault,
                billId: billId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required EntryType type,
                required int amountCents,
                required LocalDate localDate,
                required DateTime createdAtUtc,
                required String timeZoneId,
                Value<String?> merchant = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<Mood?> mood = const Value.absent(),
                Value<bool?> planned = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> splitId = const Value.absent(),
                Value<bool> toVault = const Value.absent(),
                Value<bool> fromVault = const Value.absent(),
                Value<String?> billId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntriesCompanion.insert(
                id: id,
                type: type,
                amountCents: amountCents,
                localDate: localDate,
                createdAtUtc: createdAtUtc,
                timeZoneId: timeZoneId,
                merchant: merchant,
                categoryId: categoryId,
                mood: mood,
                planned: planned,
                note: note,
                splitId: splitId,
                toVault: toVault,
                fromVault: fromVault,
                billId: billId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EntriesTable, EntryRow>(table),
                  BaseReferences<_$SteadyDatabase, $EntriesTable, EntryRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$SteadyDatabase,
      $EntriesTable,
      EntryRow,
      $$EntriesTableFilterComposer,
      $$EntriesTableOrderingComposer,
      $$EntriesTableAnnotationComposer,
      $$EntriesTableCreateCompanionBuilder,
      $$EntriesTableUpdateCompanionBuilder,
      (EntryRow, BaseReferences<_$SteadyDatabase, $EntriesTable, EntryRow>),
      EntryRow,
      PrefetchHooks Function()
    >;
typedef $$BillsTableCreateCompanionBuilder = BillsCompanion Function({
  required String id,
  required String name,
  required int amountCents,
  required Recurrence recurrence,
  required LocalDate dueDate,
  Value<bool> isEstimate,
  Value<bool> isSubscription,
  Value<bool> needsReview,
  Value<LocalDate?> lastPaidOn,
  Value<int?> previousAmountCents,
  Value<int> rowid,
});
typedef $$BillsTableUpdateCompanionBuilder = BillsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int> amountCents,
  Value<Recurrence> recurrence,
  Value<LocalDate> dueDate,
  Value<bool> isEstimate,
  Value<bool> isSubscription,
  Value<bool> needsReview,
  Value<LocalDate?> lastPaidOn,
  Value<int?> previousAmountCents,
  Value<int> rowid,
});

class $$BillsTableFilterComposer
    extends Composer<_$SteadyDatabase, $BillsTable> {
  $$BillsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Recurrence, Recurrence, String>
  get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<LocalDate, LocalDate, String> get dueDate =>
      $composableBuilder(
        column: $table.dueDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get isEstimate => $composableBuilder(
    column: $table.isEstimate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSubscription => $composableBuilder(
    column: $table.isSubscription,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get needsReview => $composableBuilder(
    column: $table.needsReview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LocalDate?, LocalDate, String>
  get lastPaidOn => $composableBuilder(
    column: $table.lastPaidOn,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get previousAmountCents => $composableBuilder(
    column: $table.previousAmountCents,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BillsTableOrderingComposer
    extends Composer<_$SteadyDatabase, $BillsTable> {
  $$BillsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEstimate => $composableBuilder(
    column: $table.isEstimate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSubscription => $composableBuilder(
    column: $table.isSubscription,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get needsReview => $composableBuilder(
    column: $table.needsReview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastPaidOn => $composableBuilder(
    column: $table.lastPaidOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get previousAmountCents => $composableBuilder(
    column: $table.previousAmountCents,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BillsTableAnnotationComposer
    extends Composer<_$SteadyDatabase, $BillsTable> {
  $$BillsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Recurrence, String> get recurrence =>
      $composableBuilder(
        column: $table.recurrence,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<LocalDate, String> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<bool> get isEstimate => $composableBuilder(
    column: $table.isEstimate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSubscription => $composableBuilder(
    column: $table.isSubscription,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get needsReview => $composableBuilder(
    column: $table.needsReview,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<LocalDate?, String> get lastPaidOn =>
      $composableBuilder(
        column: $table.lastPaidOn,
        builder: (column) => column,
      );

  GeneratedColumn<int> get previousAmountCents => $composableBuilder(
    column: $table.previousAmountCents,
    builder: (column) => column,
  );
}

class $$BillsTableTableManager
    extends
        RootTableManager<
          _$SteadyDatabase,
          $BillsTable,
          BillRow,
          $$BillsTableFilterComposer,
          $$BillsTableOrderingComposer,
          $$BillsTableAnnotationComposer,
          $$BillsTableCreateCompanionBuilder,
          $$BillsTableUpdateCompanionBuilder,
          (BillRow, BaseReferences<_$SteadyDatabase, $BillsTable, BillRow>),
          BillRow,
          PrefetchHooks Function()
        > {
  $$BillsTableTableManager(_$SteadyDatabase db, $BillsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BillsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BillsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BillsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> amountCents = const Value.absent(),
                Value<Recurrence> recurrence = const Value.absent(),
                Value<LocalDate> dueDate = const Value.absent(),
                Value<bool> isEstimate = const Value.absent(),
                Value<bool> isSubscription = const Value.absent(),
                Value<bool> needsReview = const Value.absent(),
                Value<LocalDate?> lastPaidOn = const Value.absent(),
                Value<int?> previousAmountCents = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BillsCompanion(
                id: id,
                name: name,
                amountCents: amountCents,
                recurrence: recurrence,
                dueDate: dueDate,
                isEstimate: isEstimate,
                isSubscription: isSubscription,
                needsReview: needsReview,
                lastPaidOn: lastPaidOn,
                previousAmountCents: previousAmountCents,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int amountCents,
                required Recurrence recurrence,
                required LocalDate dueDate,
                Value<bool> isEstimate = const Value.absent(),
                Value<bool> isSubscription = const Value.absent(),
                Value<bool> needsReview = const Value.absent(),
                Value<LocalDate?> lastPaidOn = const Value.absent(),
                Value<int?> previousAmountCents = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BillsCompanion.insert(
                id: id,
                name: name,
                amountCents: amountCents,
                recurrence: recurrence,
                dueDate: dueDate,
                isEstimate: isEstimate,
                isSubscription: isSubscription,
                needsReview: needsReview,
                lastPaidOn: lastPaidOn,
                previousAmountCents: previousAmountCents,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BillsTable, BillRow>(table),
                  BaseReferences<_$SteadyDatabase, $BillsTable, BillRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BillsTableProcessedTableManager =
    ProcessedTableManager<
      _$SteadyDatabase,
      $BillsTable,
      BillRow,
      $$BillsTableFilterComposer,
      $$BillsTableOrderingComposer,
      $$BillsTableAnnotationComposer,
      $$BillsTableCreateCompanionBuilder,
      $$BillsTableUpdateCompanionBuilder,
      (BillRow, BaseReferences<_$SteadyDatabase, $BillsTable, BillRow>),
      BillRow,
      PrefetchHooks Function()
    >;
typedef $$GoalsTableCreateCompanionBuilder = GoalsCompanion Function({
  required String id,
  required String name,
  required GoalKind kind,
  required int targetCents,
  required int savedCents,
  required int dailySetAsideCents,
  Value<LocalDate?> targetDate,
  Value<bool> paused,
  Value<int> sortOrder,
  Value<LocalDate?> createdOn,
  Value<int> rowid,
});
typedef $$GoalsTableUpdateCompanionBuilder = GoalsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<GoalKind> kind,
  Value<int> targetCents,
  Value<int> savedCents,
  Value<int> dailySetAsideCents,
  Value<LocalDate?> targetDate,
  Value<bool> paused,
  Value<int> sortOrder,
  Value<LocalDate?> createdOn,
  Value<int> rowid,
});

class $$GoalsTableFilterComposer
    extends Composer<_$SteadyDatabase, $GoalsTable> {
  $$GoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<GoalKind, GoalKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get targetCents => $composableBuilder(
    column: $table.targetCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get savedCents => $composableBuilder(
    column: $table.savedCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailySetAsideCents => $composableBuilder(
    column: $table.dailySetAsideCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LocalDate?, LocalDate, String>
  get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get paused => $composableBuilder(
    column: $table.paused,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LocalDate?, LocalDate, String> get createdOn =>
      $composableBuilder(
        column: $table.createdOn,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$GoalsTableOrderingComposer
    extends Composer<_$SteadyDatabase, $GoalsTable> {
  $$GoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetCents => $composableBuilder(
    column: $table.targetCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get savedCents => $composableBuilder(
    column: $table.savedCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailySetAsideCents => $composableBuilder(
    column: $table.dailySetAsideCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get paused => $composableBuilder(
    column: $table.paused,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdOn => $composableBuilder(
    column: $table.createdOn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GoalsTableAnnotationComposer
    extends Composer<_$SteadyDatabase, $GoalsTable> {
  $$GoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<GoalKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get targetCents => $composableBuilder(
    column: $table.targetCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get savedCents => $composableBuilder(
    column: $table.savedCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dailySetAsideCents => $composableBuilder(
    column: $table.dailySetAsideCents,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<LocalDate?, String> get targetDate =>
      $composableBuilder(
        column: $table.targetDate,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get paused =>
      $composableBuilder(column: $table.paused, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LocalDate?, String> get createdOn =>
      $composableBuilder(column: $table.createdOn, builder: (column) => column);
}

class $$GoalsTableTableManager
    extends
        RootTableManager<
          _$SteadyDatabase,
          $GoalsTable,
          GoalRow,
          $$GoalsTableFilterComposer,
          $$GoalsTableOrderingComposer,
          $$GoalsTableAnnotationComposer,
          $$GoalsTableCreateCompanionBuilder,
          $$GoalsTableUpdateCompanionBuilder,
          (GoalRow, BaseReferences<_$SteadyDatabase, $GoalsTable, GoalRow>),
          GoalRow,
          PrefetchHooks Function()
        > {
  $$GoalsTableTableManager(_$SteadyDatabase db, $GoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<GoalKind> kind = const Value.absent(),
                Value<int> targetCents = const Value.absent(),
                Value<int> savedCents = const Value.absent(),
                Value<int> dailySetAsideCents = const Value.absent(),
                Value<LocalDate?> targetDate = const Value.absent(),
                Value<bool> paused = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<LocalDate?> createdOn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GoalsCompanion(
                id: id,
                name: name,
                kind: kind,
                targetCents: targetCents,
                savedCents: savedCents,
                dailySetAsideCents: dailySetAsideCents,
                targetDate: targetDate,
                paused: paused,
                sortOrder: sortOrder,
                createdOn: createdOn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required GoalKind kind,
                required int targetCents,
                required int savedCents,
                required int dailySetAsideCents,
                Value<LocalDate?> targetDate = const Value.absent(),
                Value<bool> paused = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<LocalDate?> createdOn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GoalsCompanion.insert(
                id: id,
                name: name,
                kind: kind,
                targetCents: targetCents,
                savedCents: savedCents,
                dailySetAsideCents: dailySetAsideCents,
                targetDate: targetDate,
                paused: paused,
                sortOrder: sortOrder,
                createdOn: createdOn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GoalsTable, GoalRow>(table),
                  BaseReferences<_$SteadyDatabase, $GoalsTable, GoalRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$SteadyDatabase,
      $GoalsTable,
      GoalRow,
      $$GoalsTableFilterComposer,
      $$GoalsTableOrderingComposer,
      $$GoalsTableAnnotationComposer,
      $$GoalsTableCreateCompanionBuilder,
      $$GoalsTableUpdateCompanionBuilder,
      (GoalRow, BaseReferences<_$SteadyDatabase, $GoalsTable, GoalRow>),
      GoalRow,
      PrefetchHooks Function()
    >;
typedef $$VaultsTableCreateCompanionBuilder = VaultsCompanion Function({
  Value<int> id,
  required int openingBalanceCents,
  required int steadyPayWeeklyCents,
  Value<int> targetWeeks,
  Value<LocalDate?> lastReleaseDate,
});
typedef $$VaultsTableUpdateCompanionBuilder = VaultsCompanion Function({
  Value<int> id,
  Value<int> openingBalanceCents,
  Value<int> steadyPayWeeklyCents,
  Value<int> targetWeeks,
  Value<LocalDate?> lastReleaseDate,
});

class $$VaultsTableFilterComposer
    extends Composer<_$SteadyDatabase, $VaultsTable> {
  $$VaultsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get openingBalanceCents => $composableBuilder(
    column: $table.openingBalanceCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get steadyPayWeeklyCents => $composableBuilder(
    column: $table.steadyPayWeeklyCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetWeeks => $composableBuilder(
    column: $table.targetWeeks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LocalDate?, LocalDate, String>
  get lastReleaseDate => $composableBuilder(
    column: $table.lastReleaseDate,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );
}

class $$VaultsTableOrderingComposer
    extends Composer<_$SteadyDatabase, $VaultsTable> {
  $$VaultsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get openingBalanceCents => $composableBuilder(
    column: $table.openingBalanceCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get steadyPayWeeklyCents => $composableBuilder(
    column: $table.steadyPayWeeklyCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetWeeks => $composableBuilder(
    column: $table.targetWeeks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastReleaseDate => $composableBuilder(
    column: $table.lastReleaseDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VaultsTableAnnotationComposer
    extends Composer<_$SteadyDatabase, $VaultsTable> {
  $$VaultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get openingBalanceCents => $composableBuilder(
    column: $table.openingBalanceCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get steadyPayWeeklyCents => $composableBuilder(
    column: $table.steadyPayWeeklyCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetWeeks => $composableBuilder(
    column: $table.targetWeeks,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<LocalDate?, String> get lastReleaseDate =>
      $composableBuilder(
        column: $table.lastReleaseDate,
        builder: (column) => column,
      );
}

class $$VaultsTableTableManager
    extends
        RootTableManager<
          _$SteadyDatabase,
          $VaultsTable,
          VaultRow,
          $$VaultsTableFilterComposer,
          $$VaultsTableOrderingComposer,
          $$VaultsTableAnnotationComposer,
          $$VaultsTableCreateCompanionBuilder,
          $$VaultsTableUpdateCompanionBuilder,
          (VaultRow, BaseReferences<_$SteadyDatabase, $VaultsTable, VaultRow>),
          VaultRow,
          PrefetchHooks Function()
        > {
  $$VaultsTableTableManager(_$SteadyDatabase db, $VaultsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VaultsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VaultsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VaultsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> openingBalanceCents = const Value.absent(),
                Value<int> steadyPayWeeklyCents = const Value.absent(),
                Value<int> targetWeeks = const Value.absent(),
                Value<LocalDate?> lastReleaseDate = const Value.absent(),
              }) => VaultsCompanion(
                id: id,
                openingBalanceCents: openingBalanceCents,
                steadyPayWeeklyCents: steadyPayWeeklyCents,
                targetWeeks: targetWeeks,
                lastReleaseDate: lastReleaseDate,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int openingBalanceCents,
                required int steadyPayWeeklyCents,
                Value<int> targetWeeks = const Value.absent(),
                Value<LocalDate?> lastReleaseDate = const Value.absent(),
              }) => VaultsCompanion.insert(
                id: id,
                openingBalanceCents: openingBalanceCents,
                steadyPayWeeklyCents: steadyPayWeeklyCents,
                targetWeeks: targetWeeks,
                lastReleaseDate: lastReleaseDate,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VaultsTable, VaultRow>(table),
                  BaseReferences<_$SteadyDatabase, $VaultsTable, VaultRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VaultsTableProcessedTableManager =
    ProcessedTableManager<
      _$SteadyDatabase,
      $VaultsTable,
      VaultRow,
      $$VaultsTableFilterComposer,
      $$VaultsTableOrderingComposer,
      $$VaultsTableAnnotationComposer,
      $$VaultsTableCreateCompanionBuilder,
      $$VaultsTableUpdateCompanionBuilder,
      (VaultRow, BaseReferences<_$SteadyDatabase, $VaultsTable, VaultRow>),
      VaultRow,
      PrefetchHooks Function()
    >;
typedef $$SplitsTableCreateCompanionBuilder = SplitsCompanion Function({
  required String id,
  required String personName,
  required int yourSharePercent,
  required SplitMethod method,
  Value<LocalDate?> lastSettled,
  Value<int> rowid,
});
typedef $$SplitsTableUpdateCompanionBuilder = SplitsCompanion Function({
  Value<String> id,
  Value<String> personName,
  Value<int> yourSharePercent,
  Value<SplitMethod> method,
  Value<LocalDate?> lastSettled,
  Value<int> rowid,
});

class $$SplitsTableFilterComposer
    extends Composer<_$SteadyDatabase, $SplitsTable> {
  $$SplitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get personName => $composableBuilder(
    column: $table.personName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get yourSharePercent => $composableBuilder(
    column: $table.yourSharePercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SplitMethod, SplitMethod, String> get method =>
      $composableBuilder(
        column: $table.method,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<LocalDate?, LocalDate, String>
  get lastSettled => $composableBuilder(
    column: $table.lastSettled,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );
}

class $$SplitsTableOrderingComposer
    extends Composer<_$SteadyDatabase, $SplitsTable> {
  $$SplitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get personName => $composableBuilder(
    column: $table.personName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get yourSharePercent => $composableBuilder(
    column: $table.yourSharePercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastSettled => $composableBuilder(
    column: $table.lastSettled,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SplitsTableAnnotationComposer
    extends Composer<_$SteadyDatabase, $SplitsTable> {
  $$SplitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get personName => $composableBuilder(
    column: $table.personName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get yourSharePercent => $composableBuilder(
    column: $table.yourSharePercent,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SplitMethod, String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LocalDate?, String> get lastSettled =>
      $composableBuilder(
        column: $table.lastSettled,
        builder: (column) => column,
      );
}

class $$SplitsTableTableManager
    extends
        RootTableManager<
          _$SteadyDatabase,
          $SplitsTable,
          SplitRow,
          $$SplitsTableFilterComposer,
          $$SplitsTableOrderingComposer,
          $$SplitsTableAnnotationComposer,
          $$SplitsTableCreateCompanionBuilder,
          $$SplitsTableUpdateCompanionBuilder,
          (SplitRow, BaseReferences<_$SteadyDatabase, $SplitsTable, SplitRow>),
          SplitRow,
          PrefetchHooks Function()
        > {
  $$SplitsTableTableManager(_$SteadyDatabase db, $SplitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SplitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SplitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SplitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> personName = const Value.absent(),
                Value<int> yourSharePercent = const Value.absent(),
                Value<SplitMethod> method = const Value.absent(),
                Value<LocalDate?> lastSettled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SplitsCompanion(
                id: id,
                personName: personName,
                yourSharePercent: yourSharePercent,
                method: method,
                lastSettled: lastSettled,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String personName,
                required int yourSharePercent,
                required SplitMethod method,
                Value<LocalDate?> lastSettled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SplitsCompanion.insert(
                id: id,
                personName: personName,
                yourSharePercent: yourSharePercent,
                method: method,
                lastSettled: lastSettled,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SplitsTable, SplitRow>(table),
                  BaseReferences<_$SteadyDatabase, $SplitsTable, SplitRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SplitsTableProcessedTableManager =
    ProcessedTableManager<
      _$SteadyDatabase,
      $SplitsTable,
      SplitRow,
      $$SplitsTableFilterComposer,
      $$SplitsTableOrderingComposer,
      $$SplitsTableAnnotationComposer,
      $$SplitsTableCreateCompanionBuilder,
      $$SplitsTableUpdateCompanionBuilder,
      (SplitRow, BaseReferences<_$SteadyDatabase, $SplitsTable, SplitRow>),
      SplitRow,
      PrefetchHooks Function()
    >;
typedef $$SharedExpensesTableCreateCompanionBuilder =
    SharedExpensesCompanion Function({
      required String id,
      required String name,
      required int amountCents,
      required LocalDate date,
      required bool paidByYou,
      Value<int> rowid,
    });
typedef $$SharedExpensesTableUpdateCompanionBuilder =
    SharedExpensesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> amountCents,
      Value<LocalDate> date,
      Value<bool> paidByYou,
      Value<int> rowid,
    });

class $$SharedExpensesTableFilterComposer
    extends Composer<_$SteadyDatabase, $SharedExpensesTable> {
  $$SharedExpensesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LocalDate, LocalDate, String> get date =>
      $composableBuilder(
        column: $table.date,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get paidByYou => $composableBuilder(
    column: $table.paidByYou,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SharedExpensesTableOrderingComposer
    extends Composer<_$SteadyDatabase, $SharedExpensesTable> {
  $$SharedExpensesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get paidByYou => $composableBuilder(
    column: $table.paidByYou,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SharedExpensesTableAnnotationComposer
    extends Composer<_$SteadyDatabase, $SharedExpensesTable> {
  $$SharedExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<LocalDate, String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<bool> get paidByYou =>
      $composableBuilder(column: $table.paidByYou, builder: (column) => column);
}

class $$SharedExpensesTableTableManager
    extends
        RootTableManager<
          _$SteadyDatabase,
          $SharedExpensesTable,
          SharedExpenseRow,
          $$SharedExpensesTableFilterComposer,
          $$SharedExpensesTableOrderingComposer,
          $$SharedExpensesTableAnnotationComposer,
          $$SharedExpensesTableCreateCompanionBuilder,
          $$SharedExpensesTableUpdateCompanionBuilder,
          (
            SharedExpenseRow,
            BaseReferences<
              _$SteadyDatabase,
              $SharedExpensesTable,
              SharedExpenseRow
            >,
          ),
          SharedExpenseRow,
          PrefetchHooks Function()
        > {
  $$SharedExpensesTableTableManager(
    _$SteadyDatabase db,
    $SharedExpensesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SharedExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SharedExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SharedExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> amountCents = const Value.absent(),
                Value<LocalDate> date = const Value.absent(),
                Value<bool> paidByYou = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SharedExpensesCompanion(
                id: id,
                name: name,
                amountCents: amountCents,
                date: date,
                paidByYou: paidByYou,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int amountCents,
                required LocalDate date,
                required bool paidByYou,
                Value<int> rowid = const Value.absent(),
              }) => SharedExpensesCompanion.insert(
                id: id,
                name: name,
                amountCents: amountCents,
                date: date,
                paidByYou: paidByYou,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SharedExpensesTable, SharedExpenseRow>(table),
                  BaseReferences<
                    _$SteadyDatabase,
                    $SharedExpensesTable,
                    SharedExpenseRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SharedExpensesTableProcessedTableManager =
    ProcessedTableManager<
      _$SteadyDatabase,
      $SharedExpensesTable,
      SharedExpenseRow,
      $$SharedExpensesTableFilterComposer,
      $$SharedExpensesTableOrderingComposer,
      $$SharedExpensesTableAnnotationComposer,
      $$SharedExpensesTableCreateCompanionBuilder,
      $$SharedExpensesTableUpdateCompanionBuilder,
      (
        SharedExpenseRow,
        BaseReferences<
          _$SteadyDatabase,
          $SharedExpensesTable,
          SharedExpenseRow
        >,
      ),
      SharedExpenseRow,
      PrefetchHooks Function()
    >;
typedef $$OverspendDecisionsTableCreateCompanionBuilder =
    OverspendDecisionsCompanion Function({
      required LocalDate localDate,
      required OverspendStrategy strategy,
      Value<String?> categoryId,
      Value<int> amountCents,
      Value<int> rowid,
    });
typedef $$OverspendDecisionsTableUpdateCompanionBuilder =
    OverspendDecisionsCompanion Function({
      Value<LocalDate> localDate,
      Value<OverspendStrategy> strategy,
      Value<String?> categoryId,
      Value<int> amountCents,
      Value<int> rowid,
    });

class $$OverspendDecisionsTableFilterComposer
    extends Composer<_$SteadyDatabase, $OverspendDecisionsTable> {
  $$OverspendDecisionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<LocalDate, LocalDate, String> get localDate =>
      $composableBuilder(
        column: $table.localDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<OverspendStrategy, OverspendStrategy, String>
  get strategy => $composableBuilder(
    column: $table.strategy,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OverspendDecisionsTableOrderingComposer
    extends Composer<_$SteadyDatabase, $OverspendDecisionsTable> {
  $$OverspendDecisionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get strategy => $composableBuilder(
    column: $table.strategy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OverspendDecisionsTableAnnotationComposer
    extends Composer<_$SteadyDatabase, $OverspendDecisionsTable> {
  $$OverspendDecisionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<LocalDate, String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<OverspendStrategy, String> get strategy =>
      $composableBuilder(column: $table.strategy, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => column,
  );
}

class $$OverspendDecisionsTableTableManager
    extends
        RootTableManager<
          _$SteadyDatabase,
          $OverspendDecisionsTable,
          OverspendDecisionRow,
          $$OverspendDecisionsTableFilterComposer,
          $$OverspendDecisionsTableOrderingComposer,
          $$OverspendDecisionsTableAnnotationComposer,
          $$OverspendDecisionsTableCreateCompanionBuilder,
          $$OverspendDecisionsTableUpdateCompanionBuilder,
          (
            OverspendDecisionRow,
            BaseReferences<
              _$SteadyDatabase,
              $OverspendDecisionsTable,
              OverspendDecisionRow
            >,
          ),
          OverspendDecisionRow,
          PrefetchHooks Function()
        > {
  $$OverspendDecisionsTableTableManager(
    _$SteadyDatabase db,
    $OverspendDecisionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OverspendDecisionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OverspendDecisionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OverspendDecisionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<LocalDate> localDate = const Value.absent(),
                Value<OverspendStrategy> strategy = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<int> amountCents = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OverspendDecisionsCompanion(
                localDate: localDate,
                strategy: strategy,
                categoryId: categoryId,
                amountCents: amountCents,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required LocalDate localDate,
                required OverspendStrategy strategy,
                Value<String?> categoryId = const Value.absent(),
                Value<int> amountCents = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OverspendDecisionsCompanion.insert(
                localDate: localDate,
                strategy: strategy,
                categoryId: categoryId,
                amountCents: amountCents,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OverspendDecisionsTable, OverspendDecisionRow>(
                    table,
                  ),
                  BaseReferences<
                    _$SteadyDatabase,
                    $OverspendDecisionsTable,
                    OverspendDecisionRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OverspendDecisionsTableProcessedTableManager =
    ProcessedTableManager<
      _$SteadyDatabase,
      $OverspendDecisionsTable,
      OverspendDecisionRow,
      $$OverspendDecisionsTableFilterComposer,
      $$OverspendDecisionsTableOrderingComposer,
      $$OverspendDecisionsTableAnnotationComposer,
      $$OverspendDecisionsTableCreateCompanionBuilder,
      $$OverspendDecisionsTableUpdateCompanionBuilder,
      (
        OverspendDecisionRow,
        BaseReferences<
          _$SteadyDatabase,
          $OverspendDecisionsTable,
          OverspendDecisionRow
        >,
      ),
      OverspendDecisionRow,
      PrefetchHooks Function()
    >;
typedef $$DailyNumbersTableCreateCompanionBuilder =
    DailyNumbersCompanion Function({
      required LocalDate localDate,
      required int allowanceCents,
      Value<int> rowid,
    });
typedef $$DailyNumbersTableUpdateCompanionBuilder =
    DailyNumbersCompanion Function({
      Value<LocalDate> localDate,
      Value<int> allowanceCents,
      Value<int> rowid,
    });

class $$DailyNumbersTableFilterComposer
    extends Composer<_$SteadyDatabase, $DailyNumbersTable> {
  $$DailyNumbersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<LocalDate, LocalDate, String> get localDate =>
      $composableBuilder(
        column: $table.localDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get allowanceCents => $composableBuilder(
    column: $table.allowanceCents,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyNumbersTableOrderingComposer
    extends Composer<_$SteadyDatabase, $DailyNumbersTable> {
  $$DailyNumbersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get allowanceCents => $composableBuilder(
    column: $table.allowanceCents,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyNumbersTableAnnotationComposer
    extends Composer<_$SteadyDatabase, $DailyNumbersTable> {
  $$DailyNumbersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<LocalDate, String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => column);

  GeneratedColumn<int> get allowanceCents => $composableBuilder(
    column: $table.allowanceCents,
    builder: (column) => column,
  );
}

class $$DailyNumbersTableTableManager
    extends
        RootTableManager<
          _$SteadyDatabase,
          $DailyNumbersTable,
          DailyNumberRow,
          $$DailyNumbersTableFilterComposer,
          $$DailyNumbersTableOrderingComposer,
          $$DailyNumbersTableAnnotationComposer,
          $$DailyNumbersTableCreateCompanionBuilder,
          $$DailyNumbersTableUpdateCompanionBuilder,
          (
            DailyNumberRow,
            BaseReferences<
              _$SteadyDatabase,
              $DailyNumbersTable,
              DailyNumberRow
            >,
          ),
          DailyNumberRow,
          PrefetchHooks Function()
        > {
  $$DailyNumbersTableTableManager(_$SteadyDatabase db, $DailyNumbersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyNumbersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyNumbersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyNumbersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<LocalDate> localDate = const Value.absent(),
                Value<int> allowanceCents = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyNumbersCompanion(
                localDate: localDate,
                allowanceCents: allowanceCents,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required LocalDate localDate,
                required int allowanceCents,
                Value<int> rowid = const Value.absent(),
              }) => DailyNumbersCompanion.insert(
                localDate: localDate,
                allowanceCents: allowanceCents,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DailyNumbersTable, DailyNumberRow>(table),
                  BaseReferences<
                    _$SteadyDatabase,
                    $DailyNumbersTable,
                    DailyNumberRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyNumbersTableProcessedTableManager =
    ProcessedTableManager<
      _$SteadyDatabase,
      $DailyNumbersTable,
      DailyNumberRow,
      $$DailyNumbersTableFilterComposer,
      $$DailyNumbersTableOrderingComposer,
      $$DailyNumbersTableAnnotationComposer,
      $$DailyNumbersTableCreateCompanionBuilder,
      $$DailyNumbersTableUpdateCompanionBuilder,
      (
        DailyNumberRow,
        BaseReferences<_$SteadyDatabase, $DailyNumbersTable, DailyNumberRow>,
      ),
      DailyNumberRow,
      PrefetchHooks Function()
    >;

class $SteadyDatabaseManager {
  final _$SteadyDatabase _db;
  $SteadyDatabaseManager(this._db);
  $$SettingsRowsTableTableManager get settingsRows =>
      $$SettingsRowsTableTableManager(_db, _db.settingsRows);
  $$CyclePlansTableTableManager get cyclePlans =>
      $$CyclePlansTableTableManager(_db, _db.cyclePlans);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$EntriesTableTableManager get entries =>
      $$EntriesTableTableManager(_db, _db.entries);
  $$BillsTableTableManager get bills =>
      $$BillsTableTableManager(_db, _db.bills);
  $$GoalsTableTableManager get goals =>
      $$GoalsTableTableManager(_db, _db.goals);
  $$VaultsTableTableManager get vaults =>
      $$VaultsTableTableManager(_db, _db.vaults);
  $$SplitsTableTableManager get splits =>
      $$SplitsTableTableManager(_db, _db.splits);
  $$SharedExpensesTableTableManager get sharedExpenses =>
      $$SharedExpensesTableTableManager(_db, _db.sharedExpenses);
  $$OverspendDecisionsTableTableManager get overspendDecisions =>
      $$OverspendDecisionsTableTableManager(_db, _db.overspendDecisions);
  $$DailyNumbersTableTableManager get dailyNumbers =>
      $$DailyNumbersTableTableManager(_db, _db.dailyNumbers);
}
