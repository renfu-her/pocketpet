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
  int hunger = 50;
  int mood = 50;
  int interaction = 0;

  double position = 100; // 烏龜的 left 位置
  int direction = 0; // 0: front, 1: left, 2: right
  late Timer timer;
  Timer? statusTimer;
  final double step = 60; // 每次移動的距離
  final double minLeft = 20; // 左邊界
  double maxLeft = 200; // 右邊界，需根據螢幕寬度調整
  Timer? hungerTimer;
  int stamina = 100; // 體力 1~100
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
      startStatusTimer();
      startHungerTimer();
      startStaminaTimer();
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

  void startStatusTimer() {
    void scheduleNext() {
      final rand = Random();
      int next = 3 + rand.nextInt(3); // 3~5 秒
      statusTimer = Timer(Duration(seconds: next), () {
        updateMoodRandomly();
        scheduleNext();
      });
    }
    scheduleNext();
  }

  void updateMoodRandomly() {
    setState(() {
      final rand = Random();
      int moodChange = rand.nextInt(5) - 2; // -2~2
      if (hunger > 90) {
        moodChange = -(4 + rand.nextInt(5)); // -4~-8
      } else if (hunger > 70) {
        moodChange = -(2 + rand.nextInt(4)); // -2~-5
      }
      mood = (mood + moodChange).clamp(1, 100);
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
      mood = (mood + 12).clamp(1, 100); // 陪玩時心情上升更多
      stamina = (stamina - 10).clamp(0, 100); // 陪玩消耗體力
      interaction += 1;
    });
  }

  void startStaminaTimer() {
    staminaTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!isSleeping) {
        setState(() {
          stamina = (stamina - 5).clamp(0, 100);
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

  void startSleep() {
    sleepTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      setState(() {
        // 睡覺時回復體力、心情
        final rand = Random();
        stamina = (stamina + (2 + rand.nextInt(5))).clamp(0, 100); // +2~6
        mood = (mood + (2 + rand.nextInt(5))).clamp(1, 100); // +2~6
        // 飢餓照常增加（由 hungerTimer 控制）
        // 判斷是否該醒來
        final now = DateTime.now();
        bool sleepTimeUp = sleepStartTime != null && now.difference(sleepStartTime!).inSeconds >= sleepDurationSec;
        bool hungerWake = hunger > 60;
        bool staminaFull = stamina >= 100;
        if (isSleeping && timer.isActive) {
          timer.cancel(); // 睡覺時停止移動
        }
        if (sleepTimeUp || hungerWake || staminaFull) {
          isSleeping = false;
          lastSleepEndTime = now;
          sleepTimer?.cancel();
          startMoving(); // 醒來時恢復移動
        }
      });
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
    statusTimer?.cancel();
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
      backgroundColor: Colors.brown[200],
      appBar: AppBar(
        title: const Text('電子烏龜寵物'),
        backgroundColor: Colors.brown,
      ),
      body: Column(
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
                if (isSleeping)
                  Center(
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
                          Text('我先睡覺，以恢復體力', style: TextStyle(fontSize: 18)),
                        ],
                      ),
                    ),
                  )
                else if (getHungerMessage() != null)
                  Center(
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
                          Text(getHungerMessage()!, style: TextStyle(fontSize: 18)),
                        ],
                      ),
                    ),
                  )
                else if (currentNormalMessage != null)
                  Center(
                    child: AnimatedOpacity(
                      opacity: showNormalMessage ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
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
                            Text(currentNormalMessage!, style: TextStyle(fontSize: 18)),
                          ],
                        ),
                      ),
                    ),
                  ),
                // 烏龜圖片在下方
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  margin: EdgeInsets.only(left: position, top: 60), // top: 60 增加與對話框距離
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
                        label: const Text('餵食'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: isSleeping ? null : play,
                        icon: const Icon(Icons.sports_handball),
                        label: const Text('陪玩'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar(String label, int value, Color color, Color bgColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
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
