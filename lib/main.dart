import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  runApp(const TortoisePetApp());
}

class TortoisePetApp extends StatelessWidget {
  const TortoisePetApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TortoiseHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TortoiseHomePage extends StatefulWidget {
  @override
  State<TortoiseHomePage> createState() => _TortoiseHomePageState();
}

class _TortoiseHomePageState extends State<TortoiseHomePage> {
  // 飢餓程度，會隨時間自動增加，範圍 1~100
  int hunger = 30; // 初始飢餓度 30%
  int mood = 60;   // 初始心情 60%
  int interaction = 0;

  double position = 100; // 烏龜的 left 位置
  int direction = 0; // 0: front, 1: left, 2: right
  late Timer timer;
  Timer? statusTimer;
  final double step = 60; // 每次移動的距離
  final double minLeft = 20; // 左邊界
  double maxLeft = 200; // 右邊界，需根據螢幕寬度調整
  Timer? hungerTimer;
  int stamina = 60; // 初始體力 60%
  bool isSleeping = false;
  Timer? staminaTimer;
  Timer? sleepTimer;
  DateTime? sleepStartTime;
  int sleepDurationSec = 0;
  DateTime? lastSleepEndTime;
  int minSleepSec = 300; // 5分鐘
  int maxSleepSec = 600; // 10分鐘
  int minAwakeSec = 900; // 15分鐘
  int maxAwakeSec = 1500; // 25分鐘

  final List<String> normalMessages = [
    '我好慢～但好可愛！',
    '今天也要努力爬！',
    '我在思考龜生。',
    '今天也要冒險！',
    '慢慢來比較快～',
    '龜龜出動！',
  ];
  String? lastNormalMessage;

  Timer? normalMsgTimer;
  Timer? normalMsgDelayTimer;
  String? currentNormalMessage;
  bool showNormalMessage = true;

  Timer? awakeStatusTimer;
  Timer? sleepScheduleTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenWidth = MediaQuery.of(context).size.width;
      setState(() {
        maxLeft = screenWidth - 200 - minLeft; // 200為烏龜寬度
        if (position > maxLeft) position = maxLeft;
      });
      startMoving();
      startAwakeStatusTimer();
      startSleepScheduler();
      startNormalMsgTimer();
    });
  }

  void startMoving() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      moveRandomly();
    });
  }

  void startHungerTimer() {
    hungerTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      increaseHunger();
    });
  }

  void increaseHunger() {
    setState(() {
      final rand = Random();
      hunger = (hunger + rand.nextInt(3) + 1).clamp(1, 100);
      mood = (mood - (rand.nextInt(3) + 1)).clamp(1, 100);
    });
  }

  void startAwakeStatusTimer() {
    void scheduleNext() {
      final rand = Random();
      int next = 3 + rand.nextInt(4); // 3~6 秒
      awakeStatusTimer = Timer(Duration(seconds: next), () {
        if (!isSleeping) {
          setState(() {
            hunger = (hunger + (2 + rand.nextInt(3))).clamp(0, 100); // +2~4
            stamina = (stamina + (1 + rand.nextInt(3))).clamp(0, 100); // +1~3
            if (stamina > 100) stamina = 100;
            mood = (mood - (2 + rand.nextInt(4))).clamp(0, 100); // -2~5
          });
        }
        scheduleNext();
      });
    }
    scheduleNext();
  }

  void startSleepScheduler() {
    sleepScheduleTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      if (!isSleeping) startSleep();
    });
  }

  void startSleep() {
    setState(() {
      isSleeping = true;
    });
    sleepTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      setState(() {
        final rand = Random();
        stamina = (stamina + (2 + rand.nextInt(3))).clamp(0, 100); // +2~4
        mood = (mood + (1 + rand.nextInt(3))).clamp(0, 100); // +1~3
        hunger = (hunger + (2 + rand.nextInt(3))).clamp(0, 100); // +2~4
        if (hunger >= 70 || stamina >= 100) {
          isSleeping = false;
          sleepTimer?.cancel();
        }
      });
    });
  }

  void moveRandomly() {
    if (isSleeping) return; // 睡覺時不移動
    setState(() {
      final rand = Random();
      int moveDir = rand.nextInt(3); // 0:不動, 1:左, 2:右
      if (moveDir == 1 && position > minLeft) {
        position = max(position - step, minLeft);
        direction = 1; // 左
      } else if (moveDir == 2 && position < maxLeft) {
        position = min(position + step, maxLeft);
        direction = 2; // 右
      } else {
        direction = 0; // 正面
      }
    });
  }

  String getTortoiseImage() {
    if (isSleeping) {
      return 'assets/images/tortoise-sleep.png';
    }
    if (hunger >= 70) {
      return 'assets/images/tortoise-angry.png';
    }
    switch (direction) {
      case 1:
        return 'assets/images/tortoise-left.png';
      case 2:
        return 'assets/images/tortoise-right.png';
      default:
        return 'assets/images/tortoise.png';
    }
  }

  IconData getMoodIcon() {
    if (mood >= 70) {
      return FontAwesomeIcons.solidHeart;
    } else if (mood <= 30) {
      return FontAwesomeIcons.faceFrown;
    } else {
      return FontAwesomeIcons.faceMeh;
    }
  }

  Color getMoodColor() {
    if (mood >= 70) {
      return Colors.pink;
    } else if (mood <= 30) {
      return Colors.blueGrey;
    } else {
      return Colors.amber;
    }
  }

  String? getHungerMessage() {
    if (hunger > 80) {
      return '我快要餓死了';
    } else if (hunger > 70) {
      return '我的肚子好餓';
    }
    return null;
  }

  IconData getHungerFace() {
    if (hunger > 80) {
      return FontAwesomeIcons.faceSadTear;
    } else if (hunger > 70) {
      return FontAwesomeIcons.faceFrown;
    }
    return FontAwesomeIcons.faceSmile;
  }

  String? getNormalMessage() {
    if (isSleeping || getHungerMessage() != null) return null;
    final rand = Random();
    // 避免連續顯示同一句
    String msg;
    do {
      msg = normalMessages[rand.nextInt(normalMessages.length)];
    } while (msg == lastNormalMessage && normalMessages.length > 1);
    lastNormalMessage = msg;
    return msg;
  }

  void feed() {
    if (isSleeping) return; // 睡覺時不能互動
    setState(() {
      hunger = (hunger - 10).clamp(1, 100);
      mood = (mood + 8).clamp(1, 100); // 餵食時心情上升
      interaction += 1;
    });
  }

  void play() {
    if (isSleeping) return; // 睡覺時不能互動
    setState(() {
      final rand = Random();
      stamina = (stamina - (2 + rand.nextInt(3))).clamp(0, 100); // -2~4
      mood = (mood + (2 + rand.nextInt(3))).clamp(0, 100); // +2~4
      interaction += 1;
    });
  }

  void startStaminaTimer() {
    staminaTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!isSleeping) {
        
        setState(() {
          // 體力未滿時自動回復 2~6 點
          if (stamina < 100) {
            final rand = Random();
            stamina = (stamina + (2 + rand.nextInt(5))).clamp(1, 100); // +2~6
          }
          stamina = (stamina - 5).clamp(1, 100);
          // 判斷是否該進入睡眠
          final now = DateTime.now();
          if (stamina <= 30 &&
              (lastSleepEndTime == null ||
                now.difference(lastSleepEndTime!).inSeconds > minAwakeSec + Random().nextInt(maxAwakeSec - minAwakeSec + 1))) {
            isSleeping = true;
            timer.cancel(); // 進入睡眠時立即停止移動
            sleepStartTime = now;
            sleepDurationSec = minSleepSec + Random().nextInt(maxSleepSec - minSleepSec + 1);
            startSleep();
          }
        });
      }
    });
  }

  void startNormalMsgTimer() {
    void scheduleNext() {
      final rand = Random();
      int next = 5 + rand.nextInt(2); // 5~6 秒
      normalMsgTimer = Timer(Duration(seconds: next), () {
        setState(() {
          showNormalMessage = false;
        });
        int delay = 2 + rand.nextInt(4); // 2~5 秒
        normalMsgDelayTimer = Timer(Duration(seconds: delay), () {
          setState(() {
            currentNormalMessage = pickNewNormalMessage();
            showNormalMessage = true;
          });
          scheduleNext();
        });
      });
    }
    currentNormalMessage = pickNewNormalMessage();
    showNormalMessage = true;
    scheduleNext();
  }

  String pickNewNormalMessage() {
    final rand = Random();
    String msg;
    do {
      msg = normalMessages[rand.nextInt(normalMessages.length)];
    } while (msg == lastNormalMessage && normalMessages.length > 1);
    lastNormalMessage = msg;
    return msg;
  }

  @override
  void dispose() {
    timer.cancel();
    awakeStatusTimer?.cancel();
    sleepScheduleTimer?.cancel();
    hungerTimer?.cancel();
    staminaTimer?.cancel();
    sleepTimer?.cancel();
    normalMsgTimer?.cancel();
    normalMsgDelayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '電子烏龜寵物',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.brown,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // 主體內容置中且不會壓到底部
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 心情圖案固定在中間
                  Center(
                    child: Icon(getMoodIcon(), color: getMoodColor(), size: 60),
                  ),
                  // 對話框固定在中間，與烏龜保持距離
                  AnimatedOpacity(
                    opacity: (isSleeping || getHungerMessage() != null || currentNormalMessage != null && showNormalMessage) ? 1.0 : 0.0,
                    duration: const Duration(seconds: 1),
                    child: Builder(
                      builder: (context) {
                        if (isSleeping) {
                          return Center(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 40),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.bedtime, color: Colors.blue, size: 28),
                                  const SizedBox(width: 8),
                                  Text('我先睡覺，以恢復體力', style: TextStyle(fontSize: 18, color: Colors.black)),
                                ],
                              ),
                            ),
                          );
                        } else if (getHungerMessage() != null) {
                          return Center(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 40), // 與烏龜距離
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(getHungerFace(), color: Colors.redAccent, size: 28),
                                  const SizedBox(width: 8),
                                  Text(getHungerMessage()!, style: TextStyle(fontSize: 18, color: Colors.black)),
                                ],
                              ),
                            ),
                          );
                        } else if (currentNormalMessage != null) {
                          return Center(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 40),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.emoji_nature, color: Colors.green, size: 28),
                                  const SizedBox(width: 8),
                                  Text(currentNormalMessage!, style: TextStyle(fontSize: 18, color: Colors.black)),
                                ],
                              ),
                            ),
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                  ),
                  // 烏龜圖片在下方
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    margin: EdgeInsets.only(left: position < 0 ? 0 : position, top: 60), // top: 60 增加與對話框距離
                    child: Image.asset(getTortoiseImage(), width: 200),
                  ),
                  const SizedBox(height: 16),
                  // 橫條圖顯示三個狀態（固定寬度，排列整齊）
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildStatusBar('飢餓程度', hunger, Colors.red, Colors.red[100]!),
                        const SizedBox(height: 8),
                        _buildStatusBar('體力', stamina, Colors.blue, Colors.blue[100]!),
                        const SizedBox(height: 8),
                        _buildStatusBar('心情', mood, Colors.pink, Colors.pink[100]!),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // 下方資訊與按鈕固定在最下方
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: isSleeping ? null : feed,
                          icon: const Icon(Icons.restaurant),
                          label: const Text('餵食', style: TextStyle(color: Colors.black)),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: isSleeping ? null : play,
                          icon: const Icon(Icons.sports_handball),
                          label: const Text('陪玩', style: TextStyle(color: Colors.black)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar(String label, int value, Color color, Color bgColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.white)),
        SizedBox(
          width: 300, // 固定寬度
          child: Stack(
            children: [
              Container(
                height: 18,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              Container(
                height: 18,
                width: 3.0 * value, // 0~300
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
