import 'dart:math';
import 'package:vector_math/vector_math.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Duration doubleSecondsToDuration(double value) {
  value = value * 1000000;
  return Duration(microseconds: value.floor());
}

Duration doubleMillisecondsToDuration(double value) {
  value = value * 1000;
  return Duration(microseconds: value.floor());
}

class TetrioPlayer {
  late String userId;
  late String username;
  late DateTime state;
  late String role;
  int? avatarRevision;
  int? bannerRevision;
  DateTime? registrationTime;
  List<Badge> badges = [];
  String? bio;
  String? country;
  late int friendCount;
  late int gamesPlayed;
  late int gamesWon;
  late Duration gameTime;
  late double xp;
  late int supporterTier;
  late bool verified;
  bool? badstanding;
  bool? bot;
  late Connections connections;
  late TetraLeagueAlpha tlSeason1;
  List<RecordSingle?> sprint = [];
  List<RecordSingle?> blitz = [];
  TetrioZen? zen;
  Distinguishment? distinguishment;

  TetrioPlayer({
    required this.userId,
    required this.username,
    required this.role,
    required this.state,
    this.avatarRevision,
    this.bannerRevision,
    this.registrationTime,
    required this.badges,
    this.bio,
    this.country,
    required this.friendCount,
    required this.gamesPlayed,
    required this.gamesWon,
    required this.gameTime,
    required this.xp,
    required this.supporterTier,
    required this.verified,
    this.badstanding,
    this.bot,
    required this.connections,
    required this.tlSeason1,
    required this.sprint,
    required this.blitz,
    this.zen,
    this.distinguishment,
  });

  double get level => pow((xp / 500), 0.6) + (xp / (5000 + (max(0, xp - 4 * pow(10, 6)) / 5000))) + 1;

  TetrioPlayer.fromJson(Map<String, dynamic> json, DateTime stateTime) {
    userId = json['_id'];
    username = json['username'];
    state = stateTime;
    role = json['role'];
    registrationTime = json['ts'] != null ? DateTime.parse(json['ts']) : null;
    if (json['badges'] != null) {
      json['badges'].forEach((v) {
        badges.add(Badge.fromJson(v));
      });
    }
    xp = json['xp'].toDouble();
    gamesPlayed = json['gamesplayed'];
    gamesWon = json['gameswon'];
    gameTime = doubleSecondsToDuration(json['gametime'].toDouble());
    country = json['country'];
    supporterTier = json['supporter_tier'];
    verified = json['verified'];
    tlSeason1 = TetraLeagueAlpha.fromJson(json['league']);
    avatarRevision = json['avatar_revision'];
    bannerRevision = json['banner_revision'];
    bio = json['bio'];
    connections = Connections.fromJson(json['connections']);
    distinguishment = json['distinguishment'] != null ? Distinguishment.fromJson(json['distinguishment']) : null;
    friendCount = json['friend_count'] ?? 0;
    var url = Uri.https('ch.tetr.io', 'api/users/$userId/records');
    Future response = http.get(url);
    response.then((value) {
      if (value.statusCode == 200) {
        Map jsonRecords = jsonDecode(value.body);
        sprint = jsonRecords['data']['records']['40l']['record'] != null
            ? [RecordSingle.fromJson(jsonRecords['data']['records']['40l']['record'], jsonRecords['data']['records']['40l']['rank'])]
            : [];
        blitz = jsonRecords['data']['records']['blitz']['record'] != null
            ? [RecordSingle.fromJson(jsonRecords['data']['records']['blitz']['record'], jsonRecords['data']['records']['blitz']['rank'])]
            : [];
        zen = TetrioZen.fromJson(jsonRecords['data']['zen']);
      } else {
        throw Exception('Failed to fetch player');
      }
    });
    badstanding = json['badstanding'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = userId;
    data['username'] = username;
    data['role'] = role;
    data['ts'] = registrationTime?.toString();
    data['badges'] = badges.map((v) => v.toJson()).toList();
    data['xp'] = xp;
    data['gamesplayed'] = gamesPlayed;
    data['gameswon'] = gamesWon;
    data['gametime'] = gameTime.inMicroseconds / 1000000;
    data['country'] = country;
    data['supporter_tier'] = supporterTier;
    data['verified'] = verified;
    data['league'] = tlSeason1.toJson();
    data['distinguishment'] = distinguishment?.toJson();
    data['avatar_revision'] = avatarRevision;
    data['banner_revision'] = bannerRevision;
    data['bio'] = bio;
    data['connections'] = connections.toJson();
    data['friend_count'] = friendCount;
    data['badstanding'] = badstanding;
    data['bot'] = bot;
    return data;
  }

  bool isSameState(TetrioPlayer other) {
    if (userId != other.userId) return false;
    if (username != other.username) return false;
    if (role != other.role) return false;
    if (badges != other.badges) return false;
    if (bio != other.bio) return false;
    if (country != other.country) return false;
    if (friendCount != other.friendCount) return false;
    if (gamesPlayed != other.gamesPlayed) return false;
    if (gamesWon != other.gamesWon) return false;
    if (gameTime != other.gameTime) return false;
    if (xp != other.xp) return false;
    if (supporterTier != other.supporterTier) return false;
    if (verified != other.verified) return false;
    if (badstanding != other.badstanding) return false;
    if (bot != other.bot) return false;
    if (connections != other.connections) return false;
    if (tlSeason1 != other.tlSeason1) return false;
    if (distinguishment != other.distinguishment) return false;
    return true;
  }

  @override
  String toString() {
    return "$username ($userId)";
  }

  @override
  int get hashCode => state.hashCode;

  @override
  bool operator ==(covariant TetrioPlayer other) => (userId == other.userId);
}

class Badge {
  late String badgeId;
  late String label;
  DateTime? ts;

  Badge({required this.badgeId, required this.label, this.ts});

  Badge.fromJson(Map<String, dynamic> json) {
    badgeId = json['id'];
    label = json['label'];
    ts = (json['ts'] != null && json['ts'] is String) ? DateTime.parse(json['ts']) : null; // man i love osk
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = badgeId;
    data['label'] = label;
    data['ts'] = ts?.toString();
    return data;
  }

  @override
  String toString() {
    return "Badge $label ($badgeId)";
  }

  @override
  int get hashCode => badgeId.hashCode;

  @override
  bool operator ==(covariant Badge other) => badgeId == other.badgeId;
}

class Connections {
  Discord? discord;

  Connections({this.discord});

  Connections.fromJson(Map<String, dynamic> json) {
    discord = json['discord'] != null ? Discord.fromJson(json['discord']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (discord != null) {
      data['discord'] = discord!.toJson();
    }
    return data;
  }
}

class Clears {
  late int singles;
  late int doubles;
  late int triples;
  late int quads;
  late int allClears;
  late int tSpinZeros;
  late int tSpinSingles;
  late int tSpinDoubles;
  late int tSpinTriples;
  late int tSpinQuads;
  late int tSpinMiniZeros;
  late int tSpinMiniSingles;
  late int tSpinMiniDoubles;

  Clears(
      {required this.singles,
      required this.doubles,
      required this.triples,
      required this.quads,
      required this.allClears,
      required this.tSpinZeros,
      required this.tSpinSingles,
      required this.tSpinDoubles,
      required this.tSpinTriples,
      required this.tSpinQuads,
      required this.tSpinMiniZeros,
      required this.tSpinMiniSingles,
      required this.tSpinMiniDoubles});

  Clears.fromJson(Map<String, dynamic> json) {
    singles = json['singles'];
    doubles = json['doubles'];
    triples = json['triples'];
    quads = json['quads'];
    tSpinZeros = json['realtspins'];
    tSpinMiniZeros = json['minitspins'];
    tSpinMiniSingles = json['minitspinsingles'];
    tSpinSingles = json['tspinsingles'];
    tSpinMiniDoubles = json['minitspindoubles'];
    tSpinDoubles = json['tspindoubles'];
    tSpinTriples = json['tspintriples'];
    tSpinQuads = json['tspinquads'];
    allClears = json['allclear'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['singles'] = singles;
    data['doubles'] = doubles;
    data['triples'] = triples;
    data['quads'] = quads;
    data['realtspins'] = tSpinZeros;
    data['minitspins'] = tSpinMiniZeros;
    data['minitspinsingles'] = tSpinMiniSingles;
    data['tspinsingles'] = tSpinSingles;
    data['minitspindoubles'] = tSpinMiniDoubles;
    data['tspindoubles'] = tSpinDoubles;
    data['tspintriples'] = tSpinTriples;
    data['tspinquads'] = tSpinQuads;
    data['allclear'] = allClears;
    return data;
  }
}

class Discord {
  late String id;
  late String username;

  Discord({required this.id, required this.username});

  Discord.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['username'] = username;
    return data;
  }
}

class Finesse {
  late int combo;
  late int faults;
  late int perfectPieces;

  Finesse({required this.combo, required this.faults, required this.perfectPieces});

  Finesse.fromJson(Map<String, dynamic> json) {
    combo = json['combo'];
    faults = json['faults'];
    perfectPieces = json['perfectpieces'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['combo'] = combo;
    data['faults'] = faults;
    data['perfectpieces'] = perfectPieces;
    return data;
  }
}

class EndContextSingle {
  late String gameType;
  late int topBtB;
  late int topCombo;
  late int holds;
  late int inputs;
  late int level;
  late int piecesPlaced;
  late int lines;
  late int score;
  late int seed;
  late Duration finalTime;
  late int tSpins;
  late Clears clears;
  late Finesse finesse;

  double get pps => piecesPlaced / (finalTime.inMicroseconds / 1000000);
  double get kpp => inputs / piecesPlaced;
  double get spp => score / piecesPlaced;
  double get kps => inputs / (finalTime.inMicroseconds / 1000000);
  double get finessePercentage => finesse.perfectPieces / piecesPlaced;

  EndContextSingle(
      {required this.gameType,
      required this.topBtB,
      required this.topCombo,
      required this.holds,
      required this.inputs,
      required this.level,
      required this.piecesPlaced,
      required this.lines,
      required this.score,
      required this.seed,
      required this.finalTime,
      required this.tSpins,
      required this.clears,
      required this.finesse});

  EndContextSingle.fromJson(Map<String, dynamic> json) {
    seed = json['seed'];
    lines = json['lines'];
    inputs = json['inputs'];
    holds = json['holds'] ?? 0;
    finalTime = doubleMillisecondsToDuration(json['finalTime'].toDouble());
    score = json['score'];
    level = json['level'];
    topCombo = json['topcombo'];
    topBtB = json['topbtb'];
    tSpins = json['tspins'];
    piecesPlaced = json['piecesplaced'];
    clears = Clears.fromJson(json['clears']);
    finesse = Finesse.fromJson(json['finesse']);
    gameType = json['gametype'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['seed'] = seed;
    data['lines'] = lines;
    data['inputs'] = inputs;
    data['holds'] = holds;
    data['score'] = score;
    data['level'] = level;
    data['topcombo'] = topCombo;
    data['topbtb'] = topBtB;
    data['tspins'] = tSpins;
    data['piecesplaced'] = piecesPlaced;
    data['clears'] = clears.toJson();
    data['finesse'] = finesse.toJson();
    data['finalTime'] = finalTime;
    data['gametype'] = gameType;
    return data;
  }
}

class Handling {
  late double arr;
  late double das;
  late int sdf;
  late int dcd;
  late bool cancel;
  late bool safeLock;

  Handling({required this.arr, required this.das, required this.sdf, required this.dcd, required this.cancel, required this.safeLock});

  Handling.fromJson(Map<String, dynamic> json) {
    arr = json['arr'];
    das = json['das'];
    dcd = json['dcd'];
    sdf = json['sdf'];
    safeLock = json['safelock'];
    cancel = json['cancel'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['arr'] = arr;
    data['das'] = das;
    data['dcd'] = dcd;
    data['sdf'] = sdf;
    data['safelock'] = safeLock;
    data['cancel'] = cancel;
    return data;
  }
}

class NerdStats {
  final double _apm;
  final double _pps;
  final double _vs;
  late double app;
  late double vsapm;
  late double dss;
  late double dsp;
  late double appdsp;
  late double cheese;
  late double gbe;
  late double nyaapp;
  late double area;

  NerdStats(this._apm, this._pps, this._vs) {
    app = _apm / (_pps * 60);
    vsapm = _vs / _apm;
    dss = (_vs / 100) - (_apm / 60);
    dsp = ((_vs / 100) - (_apm / 60)) / _pps;
    appdsp = app + dsp;
    cheese = (dsp * 150) + (((_vs / _apm) - 2) * 50) + (0.6 - app) * 125;
    gbe = ((app * dss) / _pps) * 2;
    nyaapp = app - 5 * tan(radians((cheese / -30) + 1));
    area = _apm * 1 + _pps * 45 + _vs * 0.444 + app * 185 + dss * 175 + dsp * 450 + gbe * 315;
  }
}

class EstTr {
  final double _apm;
  final double _pps;
  final double _vs;
  final double _rating;
  final double _rd;
  final double _app;
  final double _dss;
  final double _dsp;
  final double _gbe;
  late double esttr;
  late double srarea;
  late double statrank;

  EstTr(this._apm, this._pps, this._vs, this._rating, this._rd, this._app, this._dss, this._dsp, this._gbe) {
    srarea = (_apm * 0) + (_pps * 135) + (_vs * 0) + (_app * 290) + (_dss * 0) + (_dsp * 700) + (_gbe * 0);
    statrank = 11.2 * atan((srarea - 93) / 130) + 1;
    if (statrank <= 0) statrank = 0.001;
    double estglicko = (4.0867 * srarea + 186.68);
    double temp = (1500 - estglicko) * pi;
    double temp2 = pow((15.9056943314 * (pow(_rd, 2)) + 3527584.25978), 0.5) as double;
    double temp3 = 1 + pow(10, (temp / temp2)) as double;
    esttr = 25000 / temp3;
  }
}

class Playstyle {
  final double _apm;
  final double _pps;
  final double _vs;
  final double _rd;
  final double _app;
  final double _vsapm;
  final double _dss;
  final double _dsp;
  final double _gbe;
  final double _srarea;
  final double _statrank;
  late double opener;
  late double plonk;
  late double stride;
  late double infds;

  Playstyle(this._apm, this._pps, this._vs, this._rd, this._app, this._vsapm, this._dss, this._dsp, this._gbe, this._srarea, this._statrank) {
    double nmapm = ((_apm / _srarea) / ((0.069 * pow(1.0017, (pow(_statrank, 5) / 4700))) + _statrank / 360)) - 1;
    double nmpps = ((_pps / _srarea) / (0.0084264 * pow(2.14, (-2 * (_statrank / 2.7 + 1.03))) - _statrank / 5750 + 0.0067)) - 1;
    double nmvs = ((_vs / _srarea) / (0.1333 * pow(1.0021, ((pow(_statrank, 7) * (_statrank / 16.5)) / 1400000)) + _statrank / 133)) - 1;
    double nmapp = (_app / (0.1368803292 * pow(1.0024, (pow(_statrank, 5) / 2800)) + _statrank / 54)) - 1;
    double nmdss = (_dss / (0.01436466667 * pow(4.1, ((_statrank - 9.6) / 2.9)) + _statrank / 140 + 0.01)) - 1;
    double nmdsp = (_dsp / (0.02136327583 * pow(14, ((_statrank - 14.75) / 3.9)) + _statrank / 152 + 0.022)) - 1;
    double nmgbe = (_gbe / (_statrank / 350 + 0.005948424455 * pow(3.8, ((_statrank - 6.1) / 4)) + 0.006)) - 1;
    double nmvsapm = (_vsapm / (-pow(((_statrank - 16) / 36), 2) + 2.133)) - 1;
    opener = ((nmapm + nmpps * 0.75 + nmvsapm * -10 + nmapp * 0.75 + nmdsp * -0.25) / 3.5) + 0.5;
    plonk = ((nmgbe + nmapp + nmdsp * 0.75 + nmpps * -1) / 2.73) + 0.5;
    stride = ((nmapm * -0.25 + nmpps + nmapp * -2 + nmdsp * -0.5) * 0.79) + 0.5;
    infds = ((nmdsp + nmapp * -0.75 + nmapm * 0.5 + nmvsapm * 1.5 + nmpps * 0.5) * 0.9) + 0.5;
  }
}

class EndContextMulti {
  String? userId;
  int? naturalOrder;
  int? inputs;
  int? piecesPlaced;
  Handling? handling;
  int? points;
  int? wins;
  double? secondary;
  List<double>? secondaryTracking;
  double? tertiary;
  List<double>? tertiaryTracking;
  double? extra;
  List<double>? extraTracking;
  bool? success;

  EndContextMulti(
      {this.userId,
      this.naturalOrder,
      this.inputs,
      this.piecesPlaced,
      this.handling,
      this.points,
      this.wins,
      this.secondary,
      this.secondaryTracking,
      this.tertiary,
      this.tertiaryTracking,
      this.extra,
      this.extraTracking,
      this.success});

  EndContextMulti.fromJson(Map<String, dynamic> json) {
    userId = json['user']['_id'];
    handling = json['handling'] != null ? Handling.fromJson(json['handling']) : null;
    success = json['success'];
    inputs = json['inputs'];
    piecesPlaced = json['piecesplaced'];
    naturalOrder = json['naturalorder'];
    wins = json['wins'];
    points = json['points']['primary'];
    secondary = json['points']['secondary'];
    tertiary = json['points']['tertiary'];
    secondaryTracking = json['points']['secondaryAvgTracking'].cast<double>();
    tertiaryTracking = json['points']['tertiaryAvgTracking'].cast<double>();
    extra = json['points']['extra']['vs'];
    extraTracking = json['points']['extraAvgTracking']['aggregatestats___vsscore'].cast<double>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user'] = userId;
    if (handling != null) {
      data['handling'] = handling!.toJson();
    }
    data['success'] = success;
    data['inputs'] = inputs;
    data['piecesplaced'] = piecesPlaced;
    data['naturalorder'] = naturalOrder;
    data['wins'] = wins;
    data['points']['primary'] = points;
    data['points']['secondary'] = secondary;
    data['points']['tertiary'] = tertiary;
    data['points']['extra']['vs'] = extra;
    data['points']['extraAvgTracking']['aggregatestats___vsscore'] = extraTracking;
    return data;
  }
}

class TetraLeagueAlpha {
  late int gamesPlayed;
  late int gamesWon;
  late String bestRank;
  late bool decaying;
  late double rating;
  late String rank;
  double? glicko;
  double? rd;
  late String percentileRank;
  late double percentile;
  late int standing;
  late int standingLocal;
  String? nextRank;
  late int nextAt;
  String? prevRank;
  late int prevAt;
  double? apm;
  double? pps;
  double? vs;
  NerdStats? nerdStats;
  EstTr? estTr;
  Playstyle? playstyle;
  List? records;

  TetraLeagueAlpha(
      {required this.gamesPlayed,
      required this.gamesWon,
      required this.bestRank,
      required this.decaying,
      required this.rating,
      required this.rank,
      this.glicko,
      this.rd,
      required this.percentileRank,
      required this.percentile,
      required this.standing,
      required this.standingLocal,
      this.nextRank,
      required this.nextAt,
      this.prevRank,
      required this.prevAt,
      this.apm,
      this.pps,
      this.vs,
      this.records});

  double get winrate => gamesWon / gamesPlayed;

  TetraLeagueAlpha.fromJson(Map<String, dynamic> json) {
    gamesPlayed = json['gamesplayed'];
    gamesWon = json['gameswon'];
    rating = json['rating'].toDouble();
    glicko = json['glicko']?.toDouble();
    rd = json['rd']?.toDouble();
    rank = json['rank'];
    bestRank = json['bestrank'].toString();
    apm = json['apm']?.toDouble();
    pps = json['pps']?.toDouble();
    vs = json['vs']?.toDouble();
    decaying = json['decaying'];
    standing = json['standing'];
    percentile = json['percentile'].toDouble();
    standingLocal = json['standing_local'];
    prevRank = json['prev_rank'];
    prevAt = json['prev_at'];
    nextRank = json['next_rank'];
    nextAt = json['next_at'];
    percentileRank = json['percentile_rank'];
    nerdStats = (apm != null && pps != null && apm != null) ? NerdStats(apm!, pps!, vs!) : null;
    estTr =
        (nerdStats != null) ? EstTr(apm!, pps!, vs!, rating, (rd != null) ? rd! : 69, nerdStats!.app, nerdStats!.dss, nerdStats!.dsp, nerdStats!.gbe) : null;
    playstyle = (nerdStats != null)
        ? Playstyle(apm!, pps!, vs!, (rd != null) ? rd! : 69, nerdStats!.app, nerdStats!.vsapm, nerdStats!.dss, nerdStats!.dsp, nerdStats!.gbe, estTr!.srarea,
            estTr!.statrank)
        : null;
  }

  double? get esttracc => (estTr != null) ? estTr!.esttr - rating : null;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['gamesplayed'] = gamesPlayed;
    data['gameswon'] = gamesWon;
    data['rating'] = rating;
    data['glicko'] = glicko;
    data['rd'] = rd;
    data['rank'] = rank;
    data['bestrank'] = bestRank;
    data['apm'] = apm;
    data['pps'] = pps;
    data['vs'] = vs;
    data['decaying'] = decaying;
    data['standing'] = standing;
    data['percentile'] = percentile;
    data['standing_local'] = standingLocal;
    data['prev_rank'] = prevRank;
    data['prev_at'] = prevAt;
    data['next_rank'] = nextRank;
    data['next_at'] = nextAt;
    data['percentile_rank'] = percentileRank;
    return data;
  }
}

class RecordSingle {
  late String userId;
  late String replayId;
  late String ownId;
  DateTime? timestamp;
  EndContextSingle? endContext;
  int? rank;

  RecordSingle({required this.userId, required this.replayId, required this.ownId, this.timestamp, this.endContext, this.rank});

  RecordSingle.fromJson(Map<String, dynamic> json, int? ran) {
    ownId = json['_id'];
    endContext = json['endcontext'] != null ? EndContextSingle.fromJson(json['endcontext']) : null;
    replayId = json['replayid'];
    timestamp = DateTime.parse(json['ts']);
    userId = json['user']['_id'];
    rank = ran;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = ownId;
    if (endContext != null) {
      data['endcontext'] = endContext!.toJson();
    }
    data['ismulti'] = false;
    data['replayid'] = replayId;
    data['ts'] = timestamp;
    data['user_id'] = userId;
    return data;
  }
}

class TetrioZen {
  late int level;
  late int score;

  TetrioZen({required this.level, required this.score});

  TetrioZen.fromJson(Map<String, dynamic> json) {
    level = json['level'];
    score = json['score'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['level'] = level;
    data['score'] = score;
    return data;
  }
}

class Distinguishment {
  late String type;
  String? detail;
  String? header;
  String? footer;

  Distinguishment({required this.type, this.detail, this.header, this.footer});

  Distinguishment.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    detail = json['detail'];
    header = json['header'];
    footer = json['footer'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['detail'] = detail;
    data['header'] = header;
    data['footer'] = footer;
    return data;
  }
}
